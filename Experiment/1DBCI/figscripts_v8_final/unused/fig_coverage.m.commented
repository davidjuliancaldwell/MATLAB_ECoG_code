%% this script will either plot all subject brains with their Montage-based
%% coverage (action 1) or collect the control electrodes and plot them all
%% on the talairach brain

subjids = {'fc9643', '26cb98', '38e116', '4568f4', '30052b', 'mg', '04b3d5'};

action = 2;
 % 1 - plot subj brains
 % 2 - tell me control trode
 %     and plot on tal brain
 
if (action == 2)
    alllocs = [];
    allvals = [];
end

for c = 1:length(subjids)
    subjid = subjids{c};
    
    [files, side] = getBCIFilesForSubjid(subjid);
    
    if (action == 1)
        load(strrep(files{1}, '.dat', '_montage.mat'));
        [~, ~, ~, ~, e] = regexp(Montage.MontageString, '([A-Za-z]+)\(.+?\)');

        for d = 1:length(e)
            e{d} = e{d}{1};
        end

        figure;

        PlotCortex(subjid, side);
        PlotElectrodes(subjid, e, [], true, false);

        if (strcmp(side,'r'))
            view(90,0);
        else
            view(270,0);
        end

        title(subjid);

    %     SaveFig(fullfile(pwd, 'figs'), ['coverage.' subjid '.sm']);
        maximize;
        SaveFig(fullfile(pwd, 'figs'), ['coverage.' subjid '.lg']);
    elseif (action == 2)
       load(strrep(files{2}, '.dat', '_montage.mat'));
       [~,~,par] = load_bcidat(files{2});
       
       subjlocs = trodeLocsFromMontage(subjid, Montage, true);
       alllocs = cat(1, alllocs, subjlocs(par.TransmitChList.NumericValue(1), :));
       fprintf('control ch for %s was %s\n', subjid, trodeNameFromMontage(par.TransmitChList.NumericValue(1), Montage));
       
       if (strcmp(side,'r'))
           subjval = 1;
       else
           subjval = 0;
       end
       
       allvals = cat(1, allvals, subjval);
    end
        
end

% alllocs(:,1) = abs(alllocs(:,1))*1.01;
% 
% if (action == 2)
%     PlotDotsDirect('tail', alllocs, allvals, 'r', [0 1], 20, 'recon_colormap', [], false);
%     maximize;
%     SaveFig(fullfile(pwd, 'figs'), 'coverage.tal.lg');
% end