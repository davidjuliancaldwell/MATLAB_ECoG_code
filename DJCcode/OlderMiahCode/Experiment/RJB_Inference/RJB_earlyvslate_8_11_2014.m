%% DJC - 8/11/2014 
% script to compare early vs. late trials for learning in the RJB task -
% uses Miah's curated data. Looking at HG changes in electrodes 

%% load curated data and information from overall screen

load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Code\Output\RJB_inference\data.mat')
load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Code\Output\RJB_inference\dataTable.mat')
load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Code\Output\RJB_inference\montageAll.mat')
load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Code\Output\RJB_inference\subjects.mat')


%%

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
    if subjid == '7ee6bc'
        mont.MontageTokenized = {'Grid(1:64)'};
    end
    montageAll = [montageAll; mont];
    
    % for PlotDots

    tsPlotTotal = [tsPlotTotal; tsPlot];
    
    
    % Keep loop running until user wants to stop 
    a = input('Please input a 1 if you wish to load another patient, otherwise 0 to quit ');
    count = count + 1; 

end

%% make table, summarize data,

dataTable = struct2table(data,'rownames',subjects);