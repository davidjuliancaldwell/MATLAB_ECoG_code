function ScreenBadChannels(subjID, forceScreen, screenType)

%     subjID = genPID(subjID);

    global gLastMontage;
    global gForceScreen;
    global gPatientDir;
    global gSubjID;
    global gConstantForAll
    global gScreenType;
    gConstantForAll = [];

    gLastMontage = [];

    if ~exist('forceScreen')
        gForceScreen = [];
    else
        gForceScreen = forceScreen;
    end
    
    if ~exist('screenType')
        gScreenType = [];
    else
        gScreenType = screenType;
    end
    
    gSubjID = subjID;
    %FOR DEBUGGING
%     gSubjID = 'octb09';

    gPatientDir = [myGetenv('subject_dir') '\' gSubjID '\'];
%     gPatientDir = ['d:\data\patients\' gSubjID '\'];
%     gPatientDir = ['c:\research\data\patients\' gSubjID '\'];

    ProcessDir(gPatientDir)
    
    fprintf('DONE\n');
end

function ProcessDir(directory)

    global gLastMontage;
    global gForceScreen;
    global gConstantForAll;
    global gScreenType;

    fprintf('Processing directory %s\n', directory);

    subDirs = dir(directory);
    subDirs = subDirs([subDirs.isdir]);
    subDirs = {subDirs.name};
    
    % Do processing here
    
    if isempty(gScreenType)
        bciDatFiles = dir([directory '*.dat']);
    else
        bciDatFiles = dir([directory '*' gScreenType '*.dat']);
    end
    
    for datFile = bciDatFiles'
        if isempty(datFile)
            break;
        end
        datFile = [directory datFile.name];
        if isempty(gForceScreen) || gForceScreen == 0
            cachedFile = GetCacheFile(datFile);
            if ~isempty(cachedFile)
                fprintf('  Detected cached montage for file %s\n',datFile(find(datFile=='\',1,'last'):end));
                gLastMontage = load(cachedFile,'Montage');
                gLastMontage = gLastMontage.Montage;
                continue
            end
        end
        
        %Screening required
        Montage = [];
        if ~isempty(gLastMontage)
            if gConstantForAll == 1
                Montage = gLastMontage;   
            else
                fprintf('Current File: %s\n', datFile);
                while 1
                    fprintf(' Previous Montage:\n');
                    offset = 0;
                    for i=1:length(gLastMontage.Montage)
                        fprintf('  %3i-%3i = %s\n', offset+1,offset+gLastMontage.Montage(i), gLastMontage.MontageTokenized{i});
                        offset = offset + gLastMontage.Montage(i);
                    end
                    select = input('Use montage from last file? [Y/n]: ','s');
                    select = lower(select);
                    if isempty(select)
                        select = 'y';
                    end

                    switch select
                        case 'y'
                            Montage = gLastMontage;
                        case 'n' 
                        case 'c'
                            gConstantForAll = 1;
                            Montage = gLastMontage;
                        otherwise
                            fprintf('Bad choice\n');
                            continue;
                    end
                    break;
                end
            end
        end
        if isempty(Montage)
            %Get Montage
            [Montage.Montage Montage.MontageString Montage.MontageTokenized Montage.MontageTrodes] = GetMontage(datFile);
            
        end
        %screen bad channels
        Montage.BadChannels = FindBadChannels(datFile, Montage);
        save([datFile(1:strfind(datFile,'.dat')-1) '_montage.mat'],'Montage');
        gLastMontage = Montage;        
    end
    


    
    for target=subDirs
        if strcmp(target{:},'..') == 1 || strcmp(target{:},'.') == 1
            continue
        end
        ProcessDir([directory target{:} '\']);
    end
end

function out = GetCacheFile(file)
    cacheFileName = [file(1:strfind(file,'.dat')-1) '_montage.mat'];
    try
        f = whos('-file',cacheFileName);
        out = cacheFileName;
    catch
        out = [];
    end
end
    

function [mont mstr mstrtok mtrodes] = GetMontage(datFile)
    global gPatientDir;
    global gSubjID;
    fprintf('>Montage Creation\n');
    fprintf('  Available electrodes:\n');
    try
        names = who('-file',fullfile(gPatientDir, 'trodes.mat'));
    catch
        error('Couldn''t find trodes.mat for subject %s.  Have electrodes have been identified using BioImageSuite?\n', gSubjID);
    end
    for name = names'
        if strcmp(name{:},'AllTrodes') || strcmp(name{:},'TrodeNames')
            continue
        end
        fprintf('    %s\n',name{:});
    end
    fprintf('\n  File: %s\n\n', datFile);
    fprintf('  Example: Grid(1:64) FIH([6 7 8 13 15 16]) AST(1:4 [9 10 6 32:-1:20])\n\n');
    mstr = input('  Montage: ','s');
    mstrtok = regexp(mstr, '\w*\([\w\[: \]]*\)','match');
    load(fullfile(gPatientDir, 'trodes.mat'));
    mont = [];
    mtrodes = [];
    for select = mstrtok
        select = select{:};
        
        if(isempty(strfind(select, 'empty')))
            select = [select(1:end-1) ',:)'];
            eval(sprintf('mont = cat(2,mont, size(%s,1));',select));
            eval(sprintf('mtrodes = cat(1,mtrodes,%s);',select));
        else
            nc = regexp(select, ':(\d+))', 'tokens');
            n = str2num(nc{1}{1});
            
            warning ('hack');
            mont = cat(2,mont,n);
            mtrodes = cat(1,mtrodes, zeros(n,3));
        end
    end
end

function out = FindBadChannels(file, Montage)
    fprintf('Loading file %s\n', file);

    [signal states params] = load_bcidat(file);
    clear gStates gParams
    signal = double(signal);
    
    %does the data look good?
    offset = 0;
    montIdx = 0;
    BadChannels = [];
    for chans = Montage.Montage
        montIdx = montIdx + 1;
        cont = 0;
        fid = figure; 
        set(fid,'units','normalized')
        set(fid,'position',[.1 0.1 0.8 0.8]);
        set(fid,'units','pixels')
        set(fid,'PaperPositionMode','auto')
        remainingChannels = offset+1:offset+chans;
        
        autoErr = std(signal(:,remainingChannels)) > 3*mean(std(signal));
        BadChannels = [BadChannels remainingChannels(autoErr)];
        remainingChannels(autoErr) = [];
        
        subplot(3,1,1);
        imagesc(signal(:,remainingChannels)');
        subplot(3,1,2);
        plot(signal(:,remainingChannels));
        set(gca,'xlim',[0 size(signal,1)]);
        yLims = get(gca,'ylim');
        subplot(3,1,3);
        plot(signal(:,offset+find(autoErr)));
        set(gca,'xlim',[0 size(signal,1)]);
        hold on;
        plot([0 size(signal,1)],[yLims(1) yLims(1)],'k--');
        plot([0 size(signal,1)],[yLims(2) yLims(2)],'k--');
        
%         DensePlot(3,1);
        title(sprintf('%s - Select bad channels, ''d'' for done',Montage.MontageTokenized{montIdx}));
        while cont == 0
            km=waitforbuttonpress;
            switch km
                case 1
                    key = get(fid,'CurrentCharacter');
                    if key=='d'
                        cont = 1;
                        break;
                    end
                    if key=='u'
                         remainingChannels = offset+1:offset+chans;
                         BadChannels = setdiff(BadChannels,remainingChannels);
                    end
                case 0
                    mClickInfo = get(gca);
                    m_pos=round(mClickInfo.CurrentPoint(1,1:2));
                    newChannel = remainingChannels(m_pos(2));
                    remainingChannels(m_pos(2)) = [];
                    BadChannels = [BadChannels newChannel];
            end

            subplot(2,1,1);
            imagesc(signal(:,remainingChannels)');
            subplot(2,1,2);
            plot(signal(:,remainingChannels));
            set(gca,'xlim',[0 size(signal,1)]);
%             DensePlot(2,1);
            title(sprintf('%s - Select bad channels, ''d'' for done',Montage.MontageTokenized{montIdx}));
        end
        close(fid);
        
        offset = offset + chans;
    end

    if ~isempty(BadChannels)
        fprintf('Bad Channels: ');
        for i=1:length(BadChannels)
            fprintf('%3i ',BadChannels(i));
        end
        fprintf('\n');
    end
    out = BadChannels;
end