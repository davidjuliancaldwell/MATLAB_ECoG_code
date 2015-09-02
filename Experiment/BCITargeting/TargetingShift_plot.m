% setup
subjid = 'ebffea';
type   = 'all';
% plotting = 'cortex';
plotting = 'plain';

workdir = [myGetenv('matlab_devel_dir') '\experiment\BCITargeting'];
mfilename = [workdir '\' subjid '\montage.mat'];
load(mfilename);

filename = myGetenv('output_dir');    
filename = [filename '\TargetingShift_' subjid '_' type '_rs.mat'];

load([myGetenv('subject_dir') '\' subjid '\surf\' subjid '_cortex.mat']);
load([myGetenv('subject_dir') '\' subjid '\trodes.mat']);

switch (plotting)
    case 'cortex'
%        PlotCorticalDisplay(subjid,'r',Montage,{filename},@TargetingShift_plot_cb,[]);        
        error ('no implementation for cortex option');
    case 'plain'
        load(filename);
        
        upvals = squeeze(mean(rs.aggregate.epochs(:,:,rs.aggregate.targets == 1)));
        downvals = squeeze(mean(rs.aggregate.epochs(:,:,rs.aggregate.targets == 2)));
        
        for c = 1:size(downvals,1)
            [h(c), p(c)] = ttest2(upvals(c,:), downvals(c,:)); 
        end

        results = signedSquaredXCorrValue(upvals, downvals, 2);
        results(h == 0) = NaN;
        
        ctmr_dot_plot(cortex, Montage.MontageTrodes, results, 'r', [-1 1], 20);
end

% maximize(gcf);
[myGetenv('output_dir') '\EventAverage_' subjid '_' type '_' plotting]
% SaveFig(myGetenv('output_dir'), ['EventAverage_' subjid '_' type '_' plotting]);




    
    
