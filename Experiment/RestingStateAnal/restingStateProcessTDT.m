%% DJC - 5/20/2016 - Resting State Analysis script for TDT stuff


close all;clear all;clc

Z_Constants;
SUB_DIR = fullfile(myGetenv('subject_dir'));
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

prompt = {'Enter subject name','Pre or Post','Clean outliers','Plot it','Plot FFTs'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'20f8a3','pre','n','y','y'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
subjid = answer{1};
cond = (answer{2});
cleanOutliers = answer{3};
plotIt = answer{4};
fftIt = answer{5};



%%

switch subjid
    case '78283a'
        load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','78283a_RestingState','RestingState-2.mat'))
        
        fs = Wave.info.SamplingRateHz;
        ECoGData = Wave.data;
        t = [(0:size(ECoGData,1)-1)/fs];
        
        
    case '0a80cf'
        load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','0a80cf','RestingState','RestingState-2.mat'))
        
        fs = Wave.info.SamplingRateHz;
        ECoGData = Wave.data;
        t = [(0:size(ECoGData,1)-1)/fs];
        
        
    case '3f2113'
        %older one
        
        % pre bci
        %  load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','3f2113_RestingState','RestingState-1_preBCI.mat'))
        
        % post BCI
        %load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','3f2113_RestingState','RestingState-2_postBCI.mat'))
        switch cond
            case 'pre'
                load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','3f2113_RestingState','RestingState-1.mat'))
                fs = Wave.info.SamplingRateHz;
                ECoGData = Wave.data;
                t = [(0:size(ECoGData,1)-1)/fs];
                
                % post
            case 'post'
                load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','3f2113_RestingState','RestingState-4.mat'))
                
                fs = Wave.info.SamplingRateHz;
                ECoGData = Wave.data;
                t = [(0:size(ECoGData,1)-1)/fs];
                
        end
        
    case '20f8a3'
        switch cond
            case 'pre'
                % pre
                load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','20f8a3','RestingState','RestingState-1.mat'))
                
                fs = Wave.info.SamplingRateHz;
                ECoGData = Wave.data;
                
                
                % data looks funny until sample num 1220224 - only 1:48 on
                % the grid had data, so shift all the rest
                
                ECoGDataTemp = ECoGData(1:1220224,[1:48 65:end-16]);
                clear ECoGData;
                ECoGData = ECoGDataTemp;
                clear ECoGDataTemp;
                t = [(0:size(ECoGData,1)-1)/fs];
            case 'post'
                % post
                load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','20f8a3','RestingState','RestingState-2.mat'))
                
                
                fs = Wave.info.SamplingRateHz;
                ECoGData = Wave.data;
                
                ECoGDataTemp = ECoGData(1:704634,[1:48 65:end-16]);
                
                clear ECoGData;
                ECoGData = ECoGDataTemp;
                clear ECoGDataTemp;
                t = [(0:size(ECoGData,1)-1)/fs];
                
        end
end

%% load in data

if strcmp(cleanOutliers,'y')
    % vector of leftover Nans
    nansLeft = zeros(size(ECoGData,1),1);
    
    %% get rid of outliers
    for i = 1:size(ECoGData,2)
        %%
        subData = ECoGData(:,i);
        alpha = 0.05;
        ECoGDataNoOutliers = deleteoutliers(subData,alpha,1);
        tempData = ECoGDataNoOutliers;
        bd = isnan(ECoGDataNoOutliers);
        gd=find(~bd);
        
        bd([1:(min(gd)-1) (max(gd)+1):end])=0;
        ECoGDataNoOutliers(bd)=interp1(gd,tempData(gd),find(bd));
        NaNlocs = (isnan(ECoGDataNoOutliers));
        nansLeft(NaNlocs) = 1;
        %ECoGDataNaNRemove =  ECoGDataNoOutliers(~isnan(ECoGDataNoOutliers));
        ECoGDataClean(:,i) = ECoGDataNoOutliers;
        
        
        clear subdata ECoGDataNoOutliers tempData bd gd ECoGDataNaNRemove
        
        
    end
    
    ECoGData = ECoGDataclean(~nansLeft,:);
    
end

if strcmp(plotIt,'y')
    %%
    figure(1)
    for i = 1:64
        subplot(8,8,i);
        plot(t,ECoGData(:,i));
    end
    figure(2)
    for i = 65:size(ECoGData,2)
        subplot(8,8,i-64);
        plot(t,ECoGData(:,i));
    end
    
    %% load montage
    
    restingStateName = sprintf('%s_Montage.mat',subjid);
    montageFilepath = (fullfile(SUB_DIR,subjid,restingStateName));
    
    
    if (exist(montageFilepath, 'file'))
        load(montageFilepath);
    else
        % default Montage
        Montage.Montage = size(sig,2);
        Montage.MontageTokenized = {sprintf('Channel(1:%d)', size(sig,2))};
        Montage.MontageString = Montage.MontageTokenized{:};
        Montage.MontageTrodes = zeros(size(sig,2), 3);
        Montage.BadChannels = [];
        Montage.Default = true;
    end
    
    %     %there appears to be no montage for this subject currently
    %     Montage.Montage = 64;
    %     Montage.MontageTokenized = {'Grid(1:64)'};
    %     Montage.MontageString = Montage.MontageTokenized{:};
    %     Montage.MontageTrodes = zeros(64, 3);
    %     Montage.BadChannels = [];
    %     Montage.Default = true;
    
    % get electrode locations
    locs = trodeLocsFromMontage(subjid, Montage, false);
    
    % plot electrodes on brain
    % plot cortex too
    figure
    PlotCortex(subjid,'r')
    hold on
    h = scatter3(locs(:,1),locs(:,2),locs(:,3),100,'filled');
    %     PlotElectrodes(subjid)
    
    %     for chan = 1:gridSize
    %         txt = num2str(trodeLabels(chan));
    %         t = text(locs(chan,1),locs(chan,2),locs(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
    %         set(t,'clipping','on');
    %     end
    
    
    %% plot offsets
    
    %     figure
    %     a = ECoGData;
    %     c = repmat([1:size(a,2)]',[1 size(a,1)])';
    %     plot(t,(a+c));
    %     title('offsets')
    
end

if strcmp (fftIt,'y')
    
    f = [];
    P1 = [];
    
    for j = 1:size(ECoGData,2)
        [f_temp,P1_temp] = spectralAnalysisComp(fs,ECoGData(:,j));
        f(:,j) = f_temp;
        P1(:,j) = P1_temp;
        
    end
    
    figure
    for i = 1:64
        subplot(8,8,i);
        plot(f(:,i),P1(:,i));
    end
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    figure
    
    for i = 65:size(ECoGData,2)
        subplot(8,8,i-64);
        plot(f(:,i),P1(:,i));
    end
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    
    figure
    for i = 1:64
        subplot(8,8,i);
        loglog(f(:,i),P1(:,i));
    end
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    figure
    
    for i = 65:size(ECoGData,2)
        subplot(8,8,i-64);
        loglog(f(:,i),P1(:,i));
    end
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    
    
    
    
    
end

