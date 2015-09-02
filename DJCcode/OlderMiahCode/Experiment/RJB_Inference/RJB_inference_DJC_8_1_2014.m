%% script to process RJB Inference tasks - DJC - 8-1-2014 

% uses RJBscreen.m function for individual data files 

%% load curated data

% run loop until user wants to quit it
a = 1;

data = struct;
data.interestElectrodes = {};
data.interestPvalues = {};
data.interestTS = {};
subjects = {};
count = 1;

% for PlotDotsDirect
locsAll = {};
weightsAll = {};
montageAll = {};

% for PlotDots 
tsPlotTotal = {};

while a == 1
    
    % run RJBscreen function to extract useful info, stats, etc
    [h,p,ts,subjid,electrodes,mont,tsPlot] = RJBscreen();
    fprintf('This is run  #%s : Subject ID = %s \n',num2str(count),subjid);
    
    % concatenate subjid onto subjects structure
    subjects = [subjects; subjid];
    
    % concatenate electrodes of interest, pvalues, and tstat to data
    % structure 
    data.interestElectrodes = [data.interestElectrodes; electrodes];
    data.interestPvalues = [data.interestPvalues; p];
    data.interestTS = [data.interestTS; ts];
    
    % compile locs of electrodes of interest to plot all at once. 

    
    %     locsAll = [locsAll; locs];
%     weightsAll = [weightsAll; weights];
%     if subjid == '7ee6bc'
%         mont.MontageTokenized = {'Grid(1:64)'};
%     end
    montageAll = [montageAll; mont];
    
    % for PlotDots

    tsPlotTotal = [tsPlotTotal; tsPlot];
    
    
    % Keep loop running until user wants to stop 
    a = input('Please input a 1 if you wish to load another patient, otherwise 0 to quit ');
    count = count + 1; 

end

%% make table, summarize data,

dataTable = struct2table(data,'rownames',subjects);

%% plot all the electrodes at once on a brain

% we want the color limits to be the same for all sets of dots
figure;
hold on;
clims = [1 11];

for sIdx = 1:length(subjects)
% get the electrode locations
    tlocs = trodeLocsFromMontage(subjects{sIdx}, montageAll{sIdx}, true);
    tlocs = tlocs(data.interestElectrodes{sIdx},:);
    weights = ones(size(tlocs,1),1)+sIdx;
% project them all to the right hemisphere, so we can see
% left-hemispheric coverage on the right side of the brain
    tlocs = projectToHemisphere(tlocs, 'r');
% a little bookkeeping so we don't replot the brain every time
    if (sIdx == 1)
       asOverlay = false;
    else
        asOverlay = true;
    end
    % in order to make electrode labels with subject id's on the electrode
%     clims = [sIdx sIdx+1];
    labels = repmat(sIdx, length(tlocs), 1); 
    
    % and do the plotting.
    PlotDotsDirect('tail', tlocs, weights, 'r', clims, 15, 'recon_colormap', labels, true, asOverlay);
    pause; % let's pause so we can see this in action
end




