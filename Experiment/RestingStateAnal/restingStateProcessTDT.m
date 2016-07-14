%% DJC - 5/20/2016 - Resting State Analysis script for TDT stuff


close all;clear all;clc

Z_Constants;
SUB_DIR = fullfile(myGetenv('subject_dir'));
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

subjid = input('What is the subject ID?  \n','s');

switch subjid
    case '78283a'
        load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','78283a_RestingState','RestingState-2.mat'))
    case '0a80cf'
        load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','0a80cf','RestingState','RestingState-2.mat'))
    case '3f2113'
        %older one
        
        % pre bci
      %  load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','3f2113_RestingState','RestingState-1_preBCI.mat'))
        
        % post BCI
       %load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','3f2113_RestingState','RestingState-2_postBCI.mat'))
        
        % pre
        %load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','3f2113_RestingState','RestingState-1.mat'))
        
        % post
       load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','3f2113_RestingState','RestingState-4.mat'))
        
end

%% load in data

fs = Wave.info.SamplingRateHz;
ECoGData = Wave.data;

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

% %%
% figure(1)
% for i = 1:64
%     subplot(8,8,i);
%     plot(ECoGData(:,i));
% end
% figure(2)
% for i = 65:128
%     subplot(8,8,i-64);
%     plot(ECoGData(:,i));
% end
% 
% %% fake montage for plotting
% 
% % make fake montage
% 
% 
% %there appears to be no montage for this subject currently
% Montage.Montage = 64;
% Montage.MontageTokenized = {'Grid(1:64)'};
% Montage.MontageString = Montage.MontageTokenized{:};
% Montage.MontageTrodes = zeros(64, 3);
% Montage.BadChannels = [];
% Montage.Default = true;
% 
% % get electrode locations
% locs = trodeLocsFromMontage(sid, Montage, false);

%% plot offsets

a = Wave.data;
c = repmat([1:size(a,2)]',[1 size(a,1)])';
plot(a+c);