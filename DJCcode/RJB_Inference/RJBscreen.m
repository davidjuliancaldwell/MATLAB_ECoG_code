%% function to screen individual files for RJB task. DJC 8/4/2014
% purpose of this function is to load Miah's curated data, process it, run
% the statistics on it, graph it on a brain, and feed the important results
% back to the main script to allow for tabulation of data and further
% analysis on the important subsets. 

function [hInterest,pInterest,tsInterest,subjid,electrodes,montage,tsPlot] = RJBscreen()
%% load curated data

fprintf('Select file of interest \n'); 
filepath = promptForBCI2000Recording;
load(filepath);

% change filepath in order to get right part of subjid, otherwise it
% returns RJB (very filepathsensitive!) 

filepathMod = strrep(filepath,'RJB_Inference\','');
subjid = extractSubjid(filepathMod);

% to account for 7ee6bc having a bad montage
if strcmp(subjid,'7ee6bc')
   
    load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\RJB_Inference\7ee6bc_ud_motS001R01_montage.mat');
    montage = Montage;
    
end

%% break up into rest and feedback periods, take mean in the samples dimension

% bad channels are taken care of later in selection process for parts of
% interest. For the statistical analysis, taken care of below. Bad channels
% aren't compared, so are excluded from contributing to correction factor.
% And since averages are down within a channel, does not interfere with
% other channels. 

hg_rest = mean(epochs_hg(:,:,t<-preDur),3);
hg_feedback = mean(epochs_hg(:,:,t > 0.5 & t < fbDur),3);

%% do 2 sample t-test for observations across channels, left tailed, as we are looking for less than 

% bonferroni corrected - account for bad channels 
numChans = size(epochs_hg,1) - length(bad_channels);
ptarg = 0.05 / numChans;

% 'right' means mean of x (hg_rest) is greater than mean of y (hg_feedback) 

% two sample t-test
[h, p, ~, ts] = ttest2(hg_rest,hg_feedback,ptarg,'right','unequal',2);

% paired t-test 
% [h2, p2, ~, ts2] = ttest(hg_rest,hg_feedback,ptarg,'right',2);
 
% RSA value 
%[valsRSA,hRSA] = signedSquaredXCorrValue(hg_feedback,hg_rest,2,ptarg);

% find electrodes of interest

%% select information of interest to output of function 

% now accounts for bad channels, removes them from analysis, DJC 8/5/2014 

bad_channels_mask = ones(size(epochs_hg,1),1);
bad_channels_mask(bad_channels) = 0;
bad_channels_mask = logical(bad_channels_mask);

[electrodes] = find(h == 1 & bad_channels_mask);
hInterest = h(electrodes);
pInterest = p(electrodes);
tsInterest = ts.tstat(electrodes);

%% Plot cortical surfaces 

% % only plot electrodes where significant, and plot t-stat for those 
tsPlot = nan(size(epochs_hg,1),1);
tsPlot(electrodes) = ts.tstat(electrodes);
% 
% pPlot = nan(size(epochs_hg,1),1);
% pPlot(electrodes) = p(electrodes);
% 
% figure;
% PlotDots(subjid, montage.MontageTokenized, tsPlot, 'both', [0 15], 20, 'recon_colormap');
% load('recon_colormap');
% colormap(cm);
% title([subjid, ': t statistic for significant electrodes in TID of HG signal in BCI']);
% colorbar;

% 
% % figure;
% % PlotDots(subjid, montage.MontageTokenized, pPlot, 'both', [0 0.05], 20, 'recon_colormap');
% load('recon_colormap');
% colormap(cm);
% title('t statistic for significant electrodes in TID of HG signal in BCI');
% colorbar;
%% Building up data structure to do plot of all interesting electrodes on one brain. 

% will plot in the overall script, here the purpose is to build up the
% matrix 
% 
% locs = trodeLocsFromMontage(subjid,mont,true);
% locs = locs(electrodes,:);
% 
% %uniform weights of appropriate size for each iteration of plotting 
% weights = ones(length(locs),1);
% 
% % creating montage cell for use in plotting


end 