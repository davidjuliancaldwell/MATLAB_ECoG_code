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

figure, prettybox(cat(2, activityHGmeansUpAvg(:), restHGmeansUpAvg(:), activityHGmeansDownAvg(:), restHGmeansDownAvg(:)), cat(2, 3*ones(1,45),2*ones(1,45), ones(1, 45), zeros(1, 45)), [1 0 0; 0 0 1; 0 1 0; 1 0 1], 1, false);
hold on
title('Mean log HG powers for DMN BCI - subject 3f5a8c')
ylabel('Mean log HG power')
xlabel('Condition')

% legend for box plots, cannot just do legend('','',etc)
legend(findobj(gca,'Tag','Box'),'Up target activity','Up target rest','Down target activity', 'Down target rest','location','southeast')

% significance stars 

sigstar({{1,3},{1,2},{3,4}}, [pRest pDown pUp])
ylim([2 4.5])
%% Correlation coefficients 

numSamples = length(activityHGmeansUpAvgCol);

behav = [zeros(numSamples,1); ones(numSamples,1)];

rUp = corr(behav, [activityHGmeansUpAvgCol;restHGmeansUpAvgCol]);

rDown = corr(behav, [activityHGmeansDownAvgCol;restHGmeansDownAvgCol]);

rRest = corr(behav, [restHGmeansUpAvgCol;restHGmeansDownAvgCol]);
