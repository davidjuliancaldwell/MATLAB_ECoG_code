% setup
subjid = 'mg';
type   = 'im';
% plotting = 'cortex';
plotting = 'plain';

workdir = [myGetenv('matlab_devel_dir') '\experiment\dmnSuppresionBci'];
mfilename = [workdir '\' subjid '\montage.mat'];
load(mfilename);

filename = myGetenv('output_dir');    
filename = [filename '\EventAverage_' subjid '_' type '_rs'];


switch (plotting)
    case 'cortex'
        PlotCorticalDisplay(subjid,'r',Montage,{filename},@EventAverage_plot_cb,[]);        
    case 'plain'
        load(filename);
        dataObj.variables.rs = rs;
        
        upPasses = rs.aggregate.targets == 1 & rs.aggregate.results == 1;
        upFailures = rs.aggregate.targets == 1 & rs.aggregate.results == 2;
        passCount = sum(upPasses);
        failCount = sum(upFailures);
        
        dim = ceil(sqrt(size(Montage.MontageTrodes,1)));
        
        for chan = 1:size(Montage.MontageTrodes,1)
            if (sum(Montage.BadChannels == chan) == 0)
                subplot(dim,dim,chan);
                EventAverage_plot_cb(gca, chan, chan, dataObj, false, []);
                
                temp = cumsum(Montage.Montage);
                idx = find(chan <= temp, 1, 'first');
                if (idx == 1)
                    offset = 0;
                else
                    offset = temp(idx-1);
                end
                
                title(trodeNameFromMontage(chan, Montage));
            end
        end 
        mtit(strrep([subjid ', ' type ', bci (n_pass = ' num2str(passCount) ', n_fail = ' num2str(failCount) ')'], '_', '\_'),...
            'xoff', 0, 'yoff', 0.025);
end

% maximize(gcf);
[myGetenv('output_dir') '\EventAverage_' subjid '_' type '_' plotting]
% SaveFig(myGetenv('output_dir'), ['EventAverage_' subjid '_' type '_' plotting]);




    
    
