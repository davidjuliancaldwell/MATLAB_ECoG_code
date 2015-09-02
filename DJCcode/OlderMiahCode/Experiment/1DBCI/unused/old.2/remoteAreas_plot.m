% setup

targets = {'jc_ud_mot_tongue_rs', ... %1
        'hh_ud_mot_tongue_rs', ... %2
        '4568f4_ud_mot_t_rs', ... %3
        '26cb98_ud_im_t_rs', ... %4
        '30052b_ud_im_t_rs', ... %5 
        'mg_ud_im_t_rs', ... %6
        'jt2_ud_mot_tongue_rs', ... %7
        '04b3d5_ud_im_t_rs', ... %8
        'fc9643_ud_mot_t_rs', ... %9
        '38e116_ud_mot_h_rs'}; %10
    
target = targets{9};

[subjid, type] = strtok(target, '_');
type   = type(2:end);

plotting = 'cortex';

% plotting = 'plain';

outpath = myGetenv('output_dir');    
filename = [outpath '\remoteAreas\remoteAreas_' target];
mfilename = [filename '_montage'];
load(mfilename);


switch (plotting)
    case 'cortex'
        if (strcmp('fc9643_ud_mot_t_rs', target) == 1)
            side = 'r'
        else
            side = 'both'
        end
        
        PlotCorticalDisplay(subjid,side,Montage,{filename},@remoteAreas_plot_cb,[]);        
    case 'plain'
        fprintf('plain plotting not yet implemented\n');
%         load(filename);
%         dataObj.variables.rs = rs;
%         
%         upPasses = rs.aggregate.targets == 1 & rs.aggregate.results == 1;
%         upFailures = rs.aggregate.targets == 1 & rs.aggregate.results == 2;
%         passCount = sum(upPasses);
%         failCount = sum(upFailures);
%         
%         dim = ceil(sqrt(size(Montage.MontageTrodes,1)));
%         
%         for chan = 1:size(Montage.MontageTrodes,1)
%             if (sum(Montage.BadChannels == chan) == 0)
%                 subplot(dim,dim,chan);
%                 EventAverage_plot_cb(gca, chan, chan, dataObj, false, []);
%                 
%                 temp = cumsum(Montage.Montage);
%                 idx = find(chan <= temp, 1, 'first');
%                 if (idx == 1)
%                     offset = 0;
%                 else
%                     offset = temp(idx-1);

%                 end
%                 
%                 title(trodeNameFromMontage(chan, Montage));
%             end
%         end 
%         mtit(strrep([subjid ', ' type ', bci (n_pass = ' num2str(passCount) ', n_fail = ' num2str(failCount) ')'], '_', '\_'),...
%             'xoff', 0, 'yoff', 0.025);
end

% maximize(gcf);
{[myGetenv('output_dir') '\remoteAreas\'], ['remoteAreas_' target '_' plotting]}
% SaveFig(myGetenv('output_dir'), ['EventAverage_' subjid '_' type '_' plotting]);




    
    
