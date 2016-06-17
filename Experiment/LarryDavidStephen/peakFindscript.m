close all;clearvars; clc

Z_ConstantsLarryDavidStephen;


z_total_ave =[];
mag_total_ave = [];
latency_total_ave = [];
w_total_ave = [];
p_total_ave = [] ;
ccepSID = {};
chan_total = [];
betaDist_total = [];


%%
% exclude playback and the latest subject with the seizures
for i = 2:length(SIDS)-2
    sid = SIDS{i};
    %sid = input('what is the SID?\n','s');

    switch(sid)
        case 'd5cd55'
            stims = [54 62];
            goods = sort([44 45 46 52 53 55 60 61 63]);
            betaChan = 53;
            
            % have to set t_min and t_max for each subject
            %t_min = 0.004833;
            % t_min of 0.005 would find the really early ones 
            t_min = 0.008;
            t_max = 0.05;
            
        case 'c91479'
            betaChan = 64;
            stims = [55 56];
            goods = sort([ 39 40 47 48 63 64]);
            t_min = 0.008;
            t_max = 0.035;
            
        case '7dbdec'
            stims = [11 12];
            goods = sort([4 5 10 13]);
            betaChan = 4;
            t_min = 0.005;
            t_max = 0.05;
            
        case '9ab7ab'
            betaChan = 51;
            stims = [59 60];
            goods = sort([42 43 49 50 51 52 53 57 58]);
            t_min = 0.005;
            t_max = 0.0425;
            
        case '702d24'
            betaChan = 5;
            stims = [13 14];
            goods = [ 5 ];
            bads = [23 27 28 29 30 32];
            t_min = 0.008;
            t_max = 0.0425;
            
        case 'ecb43e'
            betaChan = 55;
            stims = [56 64];
            goods = sort([55 63 54 47 48]);
            t_min = 0.008;
            t_max = 0.05;
            
        case '0b5a2e'
            betaChan = 31;
            stims = [22 30];
            goods = sort([12 13 14 15 16 20 21 23 31 32 39 40]);
            % goods = [14 21 23 31];
            bads = [20 24 28];
            t_min = 0.005;
            t_max = 0.05;
            
        case '0b5a2ePlayback'
            betaChan = 31;
            stims = [22 30];
            goods = sort([12 13 14 15 16 21 23 31 32 39 40]);
            bads = [20 24 28];
            t_min = 0.005;
            t_max = 0.05;
    end
    % load in data file
    if strcmp(sid,'ecb43e')
        load(fullfile(META_DIR,[sid '_StimulationAndCCEPs_filter']));
    else
    load(fullfile(META_DIR, [sid '_StimulationAndCCEPs']));
    % load in montage for calculating distances
    end
    
    subjid = sid;
    if (strcmp(sid,'0b5a2ePlayback'))
        load(fullfile(getSubjDir('0b5a2e'), 'trodes.mat'));
    else
        load(fullfile(getSubjDir(subjid),'trodes.mat'))
    end
    
    
    
    locs = Grid;
    
    
    gridSize = 64;
    gridMatrix = [1:gridSize];
    
    % calculate distances
    
    distances = matrixDist(locs);
    
    
    betaDist = channelExtract(distances,betaChan);
    % set logical channels to be goods
    logChans = goods;
    
    % look at electrode of interest .
    % for 0b5a2e it'll be 14 to start  , also look at 31 and 23
    
    
    
    
    % using good channels add in goods - 4/6/2016 - DJC
    logChans = gridMatrix;
    logChans(goods) = 0;
    logChans = ~logical(logChans);
    
        % make matrix of distances from Beta channel
    betaDist_total = [betaDist_total betaDist(logChans)];
    
    
    % decide whether or not to plot it
    plotIt = true;
    
    % which channels to use?
    % goods = channels that I think I seeCCEPs for
    % betaChan = betaChan
    
    chans = goods;
    
    for chan = chans
        data_chan = ECoGData(:,:,chan);
        [z_ave,mag_ave,latency_ave,w_ave,p_ave,zI,magI,latencyI,wI,pI] = zscoreWithFindPeaks(data_chan,data_chan,t,t_min,t_max,plotIt);
        chan_total = [chan_total; chan];
        z_total_ave =[z_total_ave; z_ave];
        mag_total_ave = [mag_total_ave; mag_ave];
        latency_total_ave = [latency_total_ave; latency_ave];
        w_total_ave = [w_total_ave; w_ave];
        p_total_ave = [p_total_ave; p_ave] ;
    end
    
    % make cell of SID for grouping
    
    lengthToRep = length(chans);
    sidString = repmat(sid,lengthToRep,1);
    sidCell = cellstr(sidString)';
    ccepSID = [ccepSID{:} sidCell];

    
    clearvars -except SIDS i META_DIR OUTPUT_DIR ccepSID chan_total z_total_ave mag_total_ave latency_total_ave w_total_ave p_total_ave betaDist_total
    
    % [pks,locs,w,p]= findpeaks(abs(data_mean),t_new,'Annotate','extents','WidthReference','halfprom','MinPeakDistance',0.003,'sortstr','descend','minpeakheight',20e-6,'Npeaks',3)
    %        findpeaks(abs(data_mean),t_new,'Annotate','extents','WidthReference','halfprom','MinPeakDistance',0.003,'sortstr','descend','minpeakheight',20e-6,'Npeaks',3)
    %         xlabel('time (s)')
    %         ylabel('Voltage (uV)')
    %         title(['CCEP magnitude for ',sid,' : channel ',num2str(chan)])
end

bigMatrix = [betaDist_total' chan_total latency_total_ave mag_total_ave p_total_ave w_total_ave z_total_ave];
bigMatrix_categories = {'Beta Distance' 'Channel ID' 'Latency' 'Magnitude' 'Prominence' 'Width' 'Z-score Peak'};





