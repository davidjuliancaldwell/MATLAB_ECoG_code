% % %% collect data
% subjid = 'fc9643';
% % subjid = '4568f4';
% % subjid = '30052b';
% % subjid = '9ad250';
% % subjid = '38e116';
% 
% [~, odir, hemi, bads] = filesForSubjid(subjid);
% load(fullfile(odir, [subjid '_epochs_clean']), 'tgts', 'ress', 'epochs*', 'Montage', 't');
% % save(fullfile(odir, [subjid '_results']), 'hitMean_*', 'hitSEM_*', ...
% %     'missMean_*', 'missSEM_*', 'h_*', 'stats_*');

%% this is an extremely simple method to identify features, looking at predictive and reactive error responses
%  predictive meaning the signal in the N ms (parameterized below) leading
%  up to the end of the trial
%
%  reactive meaning the signal in the N ms (parameterized below) just after
%  the end of the trial

hits = tgts==ress;
misses = tgts~=ress;

preStart = 2.5;
preStop = 3;
reStart = 3;
reStop = 3.5;

nchans = size(epochs_hg, 1)-length(bads);

locs = trodeLocsFromMontage(subjid, Montage, false);
locst = trodeLocsFromMontage(subjid, Montage, true);

% feats_beta = mean(epochs_beta(:,:,t > featStart & t < featStop),3);
preFeats_hg = mean(epochs_hg(:,:,t > preStart & t < preStop),3);
preFeats_lf = mean(epochs_lf(:,:,t > preStart & t < preStop),3);
reFeats_hg  = mean(epochs_hg(:,:,t >  reStart & t <  reStop),3);
reFeats_lf  = mean(epochs_lf(:,:,t >  reStart & t <  reStop),3);

[prehs_hg, preps_hg, ~, prestats_hg] = ttest2(preFeats_hg(:,hits), preFeats_hg(:, ~hits), 'Dim', 2, 'Alpha', 0.05/nchans);
[prehs_lf, preps_lf, ~, prestats_lf] = ttest2(preFeats_lf(:,hits), preFeats_lf(:, ~hits), 'Dim', 2, 'Alpha', 0.05/nchans);
[ rehs_hg,  reps_hg, ~,  restats_hg] = ttest2( reFeats_hg(:,hits),  reFeats_hg(:, ~hits), 'Dim', 2, 'Alpha', 0.05/nchans);
[ rehs_lf,  reps_lf, ~,  restats_lf] = ttest2( reFeats_lf(:,hits),  reFeats_lf(:, ~hits), 'Dim', 2, 'Alpha', 0.05/nchans);

doPlots = true;

if (exist('doPlots', 'var') && doPlots == true)
    load('recon_colormap');

    for d = 1:4
        switch(d)
            case 1
                ts = prestats_hg.tstat;
                hs = prehs_hg;
                tit = 'Significant \gamma predictive activity';
            case 2
                ts = prestats_lf.tstat;
                hs = prehs_lf;
                tit = 'Significant LF predictive activity';
            case 3
                ts =  restats_hg.tstat;
                hs =  rehs_hg;
                tit = 'Significant \gamma reactive activity';
            case 4
                ts =  restats_lf.tstat;
                hs =  rehs_lf;
                tit = 'Significant LF reactive activity';
            otherwise
                error('WHAT?');
        end
                
        figure
        ts(hs == 0) = NaN;
        PlotDotsDirect(subjid, locs, ts, hemi, [-10 10], 10, 'recon_colormap');
        title(tit);
        colormap(cm);
        colorbar;
    end
end

%% actually extract the features and feature values
% the features of interest can be pulled out as follows:
% for the predictive hg features,
% feats = preFeats_hg(prehs_hg == 1, :)
save(fullfile(odir, [subjid '_features']), 're*', 'pre*', 'locs*', 'hits', 'misses');
 