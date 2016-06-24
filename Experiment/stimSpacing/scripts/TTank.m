classdef TTank < handle
    properties
        tank
        ttx
        block        
    end
    
    methods
        function o = TTank()
            o.ttx = actxcontrol('TTank.X');
            o.ttx.ConnectServer('Local','Me');
            o.tank = '';
            o.block = '';
        end
        
        function delete(o)
            if (o.isTankOpen)
                o.closeTank;
            end
            o.ttx.ReleaseServer;
        end
        
        % todo make destructor that releases activex control
        function result = isTankOpen(o)
            result = ~strcmp(o.tank, '');
        end
        
        function result = openTank(o, tank)
            if (o.isTankOpen)
                warning('tank already opened: %s', tank);
                result = false;
                return;
            end
            
            res = o.ttx.OpenTank(tank,'R');

            if (res == 0)
                warning('unable to open tank: %s', tank);
                result = false;
            else
                o.tank = tank;
                result = true;
            end            
        end
        
        function result = closeTank(o)
            if (~o.isTankOpen)
                warning('no tank currently open');
                result = false;
            else
                o.tank = '';
                o.ttx.CloseTank;
                result = true;
            end
        end
        
        function blocks = enumerateBlocks(o)
            if (~o.isTankOpen)
                warning('no tank currently open');
                blocks = {};
                return;
            end
            
            blockNum = 0;            
            blocks = {};
            res = o.ttx.QueryBlockName(blockNum);
            
            while (res)
                blockNum = blockNum + 1;
                blocks{blockNum} = res;
                res = o.ttx.QueryBlockName(blockNum);                
            end        
            
            blocks = unique(blocks);
        end
        
        function result = isBlockSelected(o)
            result = ~strcmp(o.block, '');
        end
        
        function result = selectBlock(o, block)
            if (~o.isTankOpen) 
                warning('no tank currently open');
                result = false;
                return;
            end
            
            res = o.ttx.SelectBlock(block);
            
            if (res == 0)
                warning('unable to select block: %s', block);
                result = false;
            else
                o.block = block;
                result = true;                
            end
        end        
        
        function result = selectHotBlock(o)
            if (~o.isTankOpen) 
                warning('no tank currently open');
                result = false;
                return;
            end
            
            hb = o.ttx.GetHotBlock();
            
            if (hb)
                res = o.ttx.SelectBlock(hb);
                if (res == 0)
                    warning('unable to select hot block.');
                    result = false;
                else
                    o.block = 'hb';
                    result = true;
                end                            
            else
                warning('no block currently being recorded');
                result = false;
            end                        
        end
        
        % arguments
        % channels (optional) = return channels, zero or empty returns data for all channels
        % t1 (optional) = start time, 0 or empty returns from beginning 
        % t2 (optional) = end time, 0 or empty returns to end
        function [data, info] = readWaveEvent(o, event, channels, t1, t2)
            if (~o.isTankOpen)
                error('No open tank');
            elseif (~o.isBlockSelected)
                error('No block selected');
            end
                
            if (~exist('channels', 'var') || isempty(channels))
                channels = 0;
            end
            if (~exist('t1', 'var') || isempty(t1))
                t1 = 0;
            end
            if (~exist('t2', 'var') || isempty(t2))
                t2 = 0;
            end
            
            % todo, check to see if event exists and is a wave event
            blockNotes = o.getBlockInfo;
            
            evIdx = -1;
            for i = 1:length(blockNotes)
                if (strcmp(blockNotes(i).name, event))
                    evIdx = i;
                    break;
                end
            end
            
            if (evIdx < 0)
                error ('event does not exist');
            end
            
            if (max(channels) > blockNotes(evIdx).nchans)
                error ('channel does not exist');
            end            
                
            if (channels == 0)
                channels = 1:blockNotes(evIdx).nchans;
            end
            
            % figure out how much memory to allocate in the activex control.
            % right now we'll use brute force and allocate 1 GB
            if (o.ttx.SetGlobalV('WavesMemLimit', 1024^3) ~= 1)
                error('unable to allocate extra memory for activex');
            end
            
            % set the globals as appropriate
            if (o.ttx.SetGlobalV('T1', t1) ~= 1)
                error('unable to set T1');
            end
            if (o.ttx.SetGlobalV('T2', t2) ~= 1)
                error('unable to set T2');
            end

            % read the data
            % start with a single channel so we can allocate a big array            
            if (o.ttx.SetGlobalV('Channel',channels(1)) ~= 1)
                error('unable to set channel');
            end
            
            tempdata = o.ttx.ReadWavesV(event);
            
            if (any(isnan(tempdata)))
                % two possibilities, one may be that we haven't alloted
                % enough memory, the other may be that this is a snip
                % segment and no snips were stored during the recording
                errmsg = o.ttx.GetError;
                if (strfind(errmsg, 'Exceeded waveform memory'))
                    error(errmsg);
                end
            end
            
            tempmeta = o.ttx.ParseEvInfoV(0,1,0);
            
            data = zeros(size(tempdata, 1), length(channels));             
            data(:, 1) = tempdata;
            meta = zeros(size(tempmeta, 1), length(channels));
            meta(:, 1) = tempmeta;
            
            clear tempdata tempmeta;
            
            for i = 2:length(channels)
                if (o.ttx.SetGlobalV('Channel',channels(i)) ~= 1)
                    error('unable to set channel');
                end

                data(:, i) = o.ttx.ReadWavesV(event);                
                
                % collect meta info
                meta(:, i) = o.ttx.ParseEvInfoV(0,1,0);
                
            end            
            
            if (~any(isnan(meta)))
                info.EventType = o.ttx.EvTypeToString(meta(2,1)); % this assumes all the same type in a multi-channel pull
                info.EventCode = o.ttx.CodeToString(meta(3,1)); % this assumes all the same type in a multi-channel pull
                info.ChannelNumbers = channels;
            
                if (length(unique(meta(9,:))) > 1)
                    warning ('multiple sampling rates detected');
                    info.SamplingRateHz = meta(9,:);
                else
                    info.SamplingRateHz = meta(9,1);
                end 
                
%                 % this is a little expensive, storage wise, but gives you the
%                 % arrival time of each sample
%                 info.TimeStamps = t1 + ((1:size(data,1))/info.SamplingRateHz);
                
            else
                info = struct;
            end            
        end
        
        % arguments
        % t1 (optional) = start time, 0 or empty returns from beginning 
        % t2 (optional) = end time, 0 or empty returns to end
        function [data, info] = readStrobeEvent(o, event, t1, t2)
            if (~o.isTankOpen)
                error('No open tank');
            elseif (~o.isBlockSelected)
                error('No block selected');
            end
                
            if (~exist('t1', 'var') || isempty(t1))
                t1 = 0;
            end
            if (~exist('t2', 'var') || isempty(t2))
                t2 = 0;
            end
            
            % todo, check to see if event exists and is a wave event
            blockNotes = o.getBlockInfo;
            
            evIdx = -1;
            for i = 1:length(blockNotes)
                if (strcmp(blockNotes(i).name, event))
                    evIdx = i;
                    break;
                end
            end
            
            if (evIdx < 0)
                error ('event does not exist');
            end
                        
            % figure out how much memory to allocate in the activex control.
            % right now we'll use brute force and allocate 1 GB
            if (o.ttx.SetGlobalV('WavesMemLimit', 1024^3) ~= 1)
                error('unable to allocate extra memory for activex');
            end
            
            % set the globals as appropriate
            if (o.ttx.SetGlobalV('T1', t1) ~= 1)
                error('unable to set T1');
            end
            if (o.ttx.SetGlobalV('T2', t2) ~= 1)
                error('unable to set T2');
            end

            % start with a single channel so we can allocate a big array            
            if (o.ttx.SetGlobalV('Channel',0) ~= 1)
                error('unable to set channel');
            end
            
            % figure out how many records to read
            maxread = 100;
            nrecs = o.ttx.ReadEventsV(maxread, event, 0, 0, 0, 0, '');
            
            while (maxread == nrecs)
                maxread = maxread * 10;
                nrecs = o.ttx.ReadEventsV(maxread, event, 0, 0, 0, 0, '');
            end
            
            % get the data for those records
            meta = o.ttx.ParseEvInfoV(0, nrecs, 0);
            data = meta(7,:);                        
            
            if (any(isnan(data)))
                error('error reading data, possibly insufficient memory allocated in activeX control, if you''re reading multiple channels at a time, consider reading them sequentially');
            end
                        
            info.EventType = o.ttx.EvTypeToString(meta(2,1)); % this assumes all the same type for each scalar
            info.EventCode = o.ttx.CodeToString(meta(3,1)); % this assumes all the same type for each scalar
            
            if (unique(meta(4,:)) ~= 0)
                error('multiple channels');
            else
                info.ChannelNumbers = 0;
            end
            
            info.TimeStamps = meta(6,:);            
        end
        
        
        function notes = getBlockInfo(o)         
            if (~o.isBlockSelected)
                error('no block selected');
            end
            
            str = o.ttx.CurBlockNotes;    

            StoreNames = regexp(str, 'NAME=StoreName;.*?VALUE=(.*?);', 'tokens');
            NChans = regexp(str, 'NAME=NumChan;.*?VALUE=(.*?);', 'tokens');
            SampleFreqs = regexp(str, 'NAME=SampleFreq;.*?VALUE=(.*?);', 'tokens');
            EvTypes = regexp(str, 'NAME=TankEvType;.*?VALUE=(.*?);', 'tokens');
            
            if (length(StoreNames) ~= length(NChans) || length(NChans) ~= length(SampleFreqs) || length(SampleFreqs) ~= length(EvTypes))
                error('problem parsing TDT notes string');
            end

            L = length(StoreNames);

            for c = 1:L
                notes(c).name = StoreNames{c}{1};
                notes(c).nchans = str2double(NChans{c}{1});
                notes(c).fs = str2double(SampleFreqs{c}{1});
                notes(c).type = o.ttx.EvTypeToString(str2double(EvTypes{c}{1}));
            end            
        end
    end
end

%     evIdx = -1;
%     for c = 1:length(notes)
%         if (strcmp(notes(c).name, event))
%             evIdx = c;
%         end
%     end
%     
%     if (evIdx <= 0)
%         ttx.CloseTank;
%         ttx.ReleaseServer;        
%         error('requested event does not exist.');
%     end
%     
%     % and that the channels requested exist
%     if (~exist('chans', 'var') || isempty(chans))
%         chans = 1:notes(evIdx).nchans;
%     end
%         
%     if (max(chans) > notes(evIdx).nchans)
%         ttx.CloseTank;
%         ttx.ReleaseServer;        
%         error('Too many channels requested from event.');
%     end
