%% DJC - 8/12/2014 
% script to compare up vs. down trials for learning in the RJB task -
% uses Miah's curated data. Looking at HG changes in electrodes. Make sure
% to load curated data and information from overall screen before hand, as
% dataTable is passed in order to extract subjectID

%% load curated data and information from overall screen

load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Code\Output\RJB_inference\data.mat')
load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Code\Output\RJB_inference\dataTable.mat')
load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Code\Output\RJB_inference\montageAll.mat')
load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Code\Output\RJB_inference\subjects.mat')


%%

% run loop until user wants to quit it
a = 1;

dataUD = struct;
dataUD.interestElectrodes = {};
dataUD.interestPvalues = {};
dataUD.interestTS = {};
dataUD.interestElectrodesUp = {};
dataUD.interestPvaluesUp = {};
dataUD.interestTSUp = {};
dataUD.interestElectrodesDown = {};
dataUD.interestPvaluesDown = {};
dataUD.interestTSDown = {};
subjectsUD = {};
count = 1;

% for PlotDotsDirect
% locsAllUD = {};
% weightsAllUD = {};
montageAllUD = {};
% 
% % for PlotDots 
% tsPlotTotal = {};

while a == 1
    
    % run RJBscreen function to extract useful info, stats, etc
    [h,p,ts,electrodes,hUp,pUp,tsUp,eUp,hDown,pDown,tsDown,eDown,subjid,mont] = RJBupDown(dataTable);
    fprintf('This is run  #%s : Subject ID = %s \n',num2str(count),subjid);
    
    % concatenate subjid onto subjects structure
    subjectsUD = [subjectsUD; subjid];
    
    % if any values are empty, turn them into NaN to enable creation of
    % table at end
    
    if isempty(h)
        h = NaN;
    end
    
    if isempty(p)
        p = NaN;
    end
    
    if isempty(ts)
        ts = NaN;
    end
    
    if isempty(electrodes)
        electrodes = NaN;
    end
    
    if isempty(hUp)
        hUp = NaN;
    end
    
    if isempty(pUp)
        pUp = NaN;
    end
    
    if isempty(tsUp)
        tsUp = NaN;
    end
    
    if isempty(eUp)
        eUp = NaN;
    end
    
    if isempty(hDown)
        hDown = NaN;
    end
    
    if isempty(pDown)
        pDown = NaN;
    end
    
    if isempty(tsDown)
        tsDown = NaN;
    end
    
    if isempty(eDown)
        eDown = NaN;
    end
    
    % concatenate electrodes of interest, pvalues, and tstat to data
    % structure 
    dataUD.interestElectrodes = [dataUD.interestElectrodes; electrodes];
    dataUD.interestPvalues = [dataUD.interestPvalues; p];
    dataUD.interestTS = [dataUD.interestTS; ts];
    dataUD.interestElectrodesUp = [dataUD.interestElectrodesUp; eUp];
    dataUD.interestPvaluesUp = [dataUD.interestPvaluesUp; pUp];
    dataUD.interestTSUp = [dataUD.interestTSUp; tsUp];
    dataUD.interestElectrodesDown = [dataUD.interestElectrodesDown; eDown];
    dataUD.interestPvaluesDown = [dataUD.interestPvaluesDown; pDown];
    dataUD.interestTSDown = [dataUD.interestTSDown; tsDown];
    % compile locs of electrodes of interest to plot all at once. 

    
    %     locsAll = [locsAll; locs];
%     weightsAll = [weightsAll; weights];
%     if subjid == '7ee6bc'
%         mont.MontageTokenized = {'Grid(1:64)'};
%     end
    montageAllUD = [montageAllUD; mont];
%     
%     % for PlotDots
% 
%     tsPlotTotal = [tsPlotTotal; tsPlot];
%     
    
    % Keep loop running until user wants to stop 
    a = input('Please input a 1 if you wish to load another patient, otherwise 0 to quit ');
    count = count + 1; 

end

%% make table, summarize data,

dataTableUD = struct2table(dataUD,'rownames',subjectsUD);

%% plot all the electrodes at once on a brain

load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Code\Output\RJB_inference\dataUDfromTableconvert.mat')
montageAllUD = montageAll;
subjectsUD = subjects; 

% we want the color limits to be the same for all sets of dots

figure;
hold on;
clims = [1 11];
firstRun = 1;

% check condition to make sure no NaN, and BE SURE TO NOTE CURRENT DIFFERENT
% STRUCTUR FOR dataUD, make sure to load "dataUDfromTable" from output RJB
% inference folder for now. Also, montageAllUD and subjectsUD MUST be same
% as original loaded ones for now, this is important for appropriate plot
% matching later. TO DO - rerun scripts to build same table, data structure,
% subjid as before. modify for up condition, down condition, etc. Add
% titles, etc 

for sIdx = 1:length(subjectsUD)
    
    if ~isnan(dataUD(sIdx).interestElectrodesDown)
        % get the electrode locations
        tlocs = trodeLocsFromMontage(subjectsUD{sIdx}, montageAllUD{sIdx}, true);
        tlocs = tlocs(dataUD(sIdx).interestElectrodesDown,:);
        weights = ones(size(tlocs,1),1)+sIdx;
        % project them all to the right hemisphere, so we can see
        % left-hemispheric coverage on the right side of the brain
        tlocs = projectToHemisphere(tlocs, 'r');
        % a little bookkeeping so we don't replot the brain every time
        if (sIdx == 1 || firstRun ==1)
            asOverlay = false;
            firstRun = 2;
        else
            asOverlay = true;
        end
        % in order to make electrode labels with subject id's on the electrode
        %     clims = [sIdx sIdx+1];
        labels = repmat(sIdx, length(tlocs), 1);
        
        % and do the plotting.
        PlotDotsDirect('tail', tlocs, weights, 'r', clims, 15, 'recon_colormap', labels, true, asOverlay);

    end
 
end

