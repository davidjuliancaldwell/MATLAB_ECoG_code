%% batchprocess_7_29_2014_f5a8c - script for batch processing of data files for DMN

% input number of files to run data analysis on

num_runs = input('How many different trials for subject? ');

% initialize matricse which will have the epoch means placed into them 
activityHGmeansUpAvg = [];
activityHGmeansDownAvg = [];
restHGmeansUpAvg = [];
restHGmeansDownAvg = [];

%% do the DMN processing one file at a time

for i = 1:num_runs
    
    % prompt user for file, extract statistics 
    filepath = promptForBCI2000Recording;
    [activityHGmeansUp, activityHGmeansDown,restHGmeansUp,restHGmeansDown] = dmnProcess(filepath);
   
    % build up matrices for analysis after (i'm assuming same size...)
    activityHGmeansUpAvg(:,i) = activityHGmeansUp;
    activityHGmeansDownAvg(:,i) = activityHGmeansDown;
    restHGmeansUpAvg(:,i) =  restHGmeansUp;
    restHGmeansDownAvg(:,i) = restHGmeansDown;
    
end

%% do the aggregate statistics , make into single column vector and do ttest2
% edited 9/3/2014 for carmel abstract figures DJC
% edited 5/7/2015 for NsF to account for Jeff's suggestions 
ptarg = 0.05;

activityHGmeansUpAvgCol = activityHGmeansUpAvg(:);
activityHGmeansDownAvgCol = activityHGmeansDownAvg(:);
restHGmeansUpAvgCol = restHGmeansUpAvg(:);
restHGmeansDownAvgCol = restHGmeansDownAvg(:);

[hDown,pDown,ciDown,statsDown] = ttest2(restHGmeansDownAvgCol,activityHGmeansDownAvgCol,ptarg,'l','unequal',1);
[hUp,pUp,ciUp,statsUp] = ttest2(restHGmeansUpAvgCol, activityHGmeansUpAvgCol, ptarg, 'r', 'unequal',1);
[hRest,pRest,ciRest,statsRest] = ttest2(restHGmeansUpAvgCol,restHGmeansDownAvgCol,ptarg,'both','unequal',1);

figure, prettybox(cat(2, activityHGmeansUpAvg(:), activityHGmeansDownAvg(:), restHGmeansUpAvg(:), restHGmeansDownAvg(:)), cat(2, 3*ones(1,45),2*ones(1,45), ones(1, 45), zeros(1, 45)), [1 0 0; 0 0 1; 0 1 0; 1 0 1], 1, false);
hold on
title('Mean log HG powers for DMN BCI - subject 3f5a8c')
ylabel('Mean log HG power')
xlabel('Condition')

% legend for box plots, cannot just do legend('','',etc)
legend(findobj(gca,'Tag','Box'),'Up target activity','Down target activity','Up target rest', 'Down target rest','location','southeast')

% significance stars 

sigstar({{1,2},{1,3},{2,4}}, [pRest pDown pUp])
ylim([2 4.5])
%% Correlation coefficients 

numSamples = length(activityHGmeansUpAvgCol);

behav = [zeros(numSamples,1); ones(numSamples,1)];

rUp = corr(behav, [activityHGmeansUpAvgCol;restHGmeansUpAvgCol]);

rDown = corr(behav, [activityHGmeansDownAvgCol;restHGmeansDownAvgCol]);

rRest = corr(behav, [restHGmeansUpAvgCol;restHGmeansDownAvgCol]);

%% DJC 10-12-2015
%Plot DMN Control Electrode
% for 3f5a8c, use D4 DMN screen montage 

elec = input('What was the control electrode? ');


%% collect appropriate information necessary to run
% filename to process
filepath = promptForBCI2000Recording;
subjid = extractSubjid(filepath);

aggregate = input('aggregate all stimuluscodes (e.g. speech tasks) - y/[n]: ','s');

if strcmpi(aggregate,'y')
    aggregate = true;
else
    aggregate = false;
end

restCode = input('rest StimulusCode (usually zero, unless finger twister): ');

%% load data and montage (if exists) in to memory
[~, ~, ext] = fileparts(filepath);

if (strcmp(ext, '.dat'))
    [sig, sta, par] = load_bcidat(filepath);
else
    load(filepath);
end

montageFilepath = strrep(filepath, '.dat', '_montage.mat');

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

%% gets the electrode locations for this subject
% in their native brain space.
locs = trodeLocsFromMontage(subjid, Montage, false);
weights = zeros(size(locs,1),1);
weights(elec) = 1;

%%
% now plot the weights on the subject specific brain. PlotDotsDirect has a
% bunch of input arguments
figure;
PlotDotsDirect(subjid, ... % the subject on who's brain the electrodes will be drawn
               locs, ... % the location of the electrodes
               weights, ... % the weights to use for coloring
               'r', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
               [-abs(max(weights)) abs(max(weights))], ... % the color limits for the weights
               20, ... % the size of the dots, in points I believe
               'recon_colormap', ... % the colormap to use for dot coloration
               1:62, ... % labels for the electrodes, I think this can be a cell array 
               true, ... % a boolean switch as to whether or not to draw the labels
               false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
                 % calls to PlotDotsDirect where you don't want to keep
                 % re-drawing the brain over itself

                 %%
                 
% very often, after plotting the brain and dots, I add a colorbar for
% reference as to what the dot colors mean
load('recon_colormap'); % needs to be the same as what was used in the function call above
colormap(cm);
colorbar;
