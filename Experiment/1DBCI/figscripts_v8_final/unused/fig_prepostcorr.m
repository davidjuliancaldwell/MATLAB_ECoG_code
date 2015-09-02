%% analysis looking at power changes in control electrode on subject by
%% subject basis

% common across all remote areas analysis scripts
subjids = {
    '26cb98'
    '04b3d5'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };

% figure;
% PlotCortex('tail', 'r');

for c = 1:length(subjids)
    fprintf('processing subjid %s\n', subjids{c});
    
    [~, side, div] = getBCIFilesForSubjid(subjids{c});
    load(['AllPower.m.cache\' subjids{c} '.mat']);
%%%     load(['AllPower.m.cache\' subjids{c} '.mat'], 'controlChannel', 'Montage');

    % assumes that fig_overall has been run
    overallcachefile = fullfile(pwd, 'cache', ['fig_overall.' subjids{c} '.mat']);
    load(overallcachefile, 'usigs', 'dsigs');
    interestingTrodes = union(find(usigs), find(dsigs));    
    interestingTrodes(interestingTrodes == controlChannel) = [];
    
%%%     % assumes that fig_bytime has been run
%%%     bytimecachefile = fullfile(pwd, 'cache', ['fig_bytime.' subjids{c} '.mat']);
%%%     load(bytimecachefile, 'allwindows', 'alltargets', 'pre', 'post', 'fb', 't', 'presamps', 'postsamps', 'fbsamps', 'fs');

%%%     subjlocs = trodeLocsFromMontage(subjids{c}, Montage, true);
    
    up = 1;
    down = 2;

    % do stuff

    ups = find(targetCodes == up);
%%%    ups = find(alltargets == up);
    preups = ups(ups < div);
    postups = ups(ups >= div);
    
    downs = find(targetCodes == down);
%%%    downs = find(alltargets == down);
    predowns = downs(downs < div);
    postdowns = downs(downs >= div);

    figure;
    dims = ceil(sqrt(length(interestingTrodes)));
    
    for d = 1:length(interestingTrodes)
        subplot(dims, dims, d);
        
        tpreu = epochZs(interestingTrodes(d), preups);
        cpreu = epochZs(controlChannel, preups);
        
        tpostu = epochZs(interestingTrodes(d), postups);
        cpostu = epochZs(controlChannel, postups);
        
        plot(cpreu, tpreu, 'rx');         hold on;        
        plot(cpostu, tpostu, 'gx');
        
        preln = polyfit(cpreu, tpreu, 1);
        prepts = preln(1)*xlim+preln(2);

        postln = polyfit(cpostu, tpostu, 1);
        postpts = postln(1)*xlim+postln(2);
        
        plot(xlim, prepts, 'r', 'LineWidth', 2);
        plot(xlim, postpts, 'g', 'LineWidth', 2);
        
%         legend('pre', 'post');
        xlabel('ctl pwr');
        ylabel('trode pwr');
        title(trodeNameFromMontage(interestingTrodes(d), Montage));
    end
    
    mtit(subjids{c}, 'xoff', 0, 'yoff', 0.025);
    
end

%         figure;
%         barweb([mean(preupcorrs) mean(postupcorrs)], [std(preupcorrs)/sqrt(length(preupcorrs)) std(postupcorrs)/sqrt(length(postupcorrs))]);
%         title(sprintf('%s %s to %s', subjids{c}, trodeNameFromMontage(controlChannel, Montage), trodeNameFromMontage(interestingTrodes(d), Montage)));
%         figure;
%         ax(1) = subplot(211);
%         hist(preupcorrs);
%         
%         ax(2) = subplot(212);
%         hist(postupcorrs);
%         
%         linkaxes(ax, 'x');
%         
%         x = 5;
%         [r, p] = corr(epochZs(controlChannel, preups)', epochZs(interestingTrodes(d), preups)')
%         [r, p] = corr(epochZs(controlChannel, postups)', epochZs(interestingTrodes(d), postups)')
% 
%         [r, p] = corr(epochZs(controlChannel, predowns)', epochZs(interestingTrodes(d), predowns)')
%         [r, p] = corr(epochZs(controlChannel, postdowns)', epochZs(interestingTrodes(d), postdowns)') 




% % %     vals = [];
% % %     sigs = [];
% % %     
% % %     for d = 1:length(interestingTrodes)
% % %         
% % %         tempbwindows = squeeze(allwindows(:,interestingTrodes(d), preups));
% % %         tempbwindows = lowpass(tempbwindows,10,fs,4);
% % %         
% % %         tempawindows = squeeze(allwindows(:,controlChannel, preups));
% % %         tempawindows = lowpass(tempawindows,10,fs,4);
% % %         
% % %         tempbwindows = tempbwindows(t > 0 & t <= fb, :, :);
% % %         tempawindows = tempawindows(t > 0 & t <= fb, :, :);
% % %         
% % %         tempb = tempbwindows;
% % %         tempa = tempawindows;
% % % 
% % % %         tempb = squeeze(allwindows(t > 0 & t <= fb, interestingTrodes(d), preups));
% % % %         tempa = squeeze(allwindows(t > 0 & t <= fb, controlChannel, preups));
% % %         
% % %         preupcorrs = zeros(1, length(preups));
% % %         
% % %         for f = 1:length(preups);
% % %             preupcorrs(f) = corr(tempa(:,f), tempb(:,f));
% % %         end        
% % % 
% % %         tempbwindows = squeeze(allwindows(:,interestingTrodes(d), postups));
% % %         tempbwindows = lowpass(tempbwindows,10,fs,4);
% % %         
% % %         tempawindows = squeeze(allwindows(:,controlChannel, postups));
% % %         tempawindows = lowpass(tempawindows,10,fs,4);
% % %         
% % %         tempbwindows = tempbwindows(t > 0 & t <= fb, :, :);
% % %         tempawindows = tempawindows(t > 0 & t <= fb, :, :);
% % %         
% % %         tempb = tempbwindows;
% % %         tempa = tempawindows;
% % %         
% % % %         tempb = squeeze(allwindows(t > 0 & t <= fb, interestingTrodes(d), postups));
% % % %         tempa = squeeze(allwindows(t > 0 & t <= fb, controlChannel, postups));
% % %         
% % %         postupcorrs = zeros(1, length(postups));
% % %         
% % %         for f = 1:length(postups);
% % %             postupcorrs(f) = corr(tempa(:,f), tempb(:,f));
% % %         end        
% % %         
% % %         [vals(d), sigs(d)] = signedSquaredXCorrValue(postupcorrs', preupcorrs');
% % %         
% % %         locs(d, :) = subjlocs(interestingTrodes(d), :);
% % %     end        
% % %     
% % %     locs(:,1) = abs(locs(:,1));
% % %     vals(sigs==0) = NaN;
% % %     
% % %     PlotDotsDirect('tail', locs, vals, 'r', [-1 1], 20, 'recon_colormap', [], false);
% % %     x = 5;
