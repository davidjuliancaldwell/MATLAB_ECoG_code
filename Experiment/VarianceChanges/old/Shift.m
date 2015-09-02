% subjid = '38e116';
% numTargets = 7;
subjid = 'fc9643';
numTargets = 5;

[odir, hemi, bads, prefix, files] = RSInTaskDataFiles(subjid, numTargets);

ftemp = files{1};

% for mfile = ftemp
%     [~,~,par] = load_bcidat(mfile{:});
%     fprintf('(%d, %d, %d) %s\n', par.ITIDuration.NumericValue, par.PreFeedbackDuration.NumericValue, par.FeedbackDuration.NumericValue, mfile{:});
% end
% return;

% d3base = fullfile(getSubjDir('fc9643'), 'data', 'D3');
% ud_im = fullfile(d3base, 'fc9643_ud_im_t001', 'fc9643_ud_im_tS001R0');
% ud_3targ = fullfile(d3base, 'fc9643_ud_3targ001', 'fc9643_ud_3targS001R0');
% ud_5targ = fullfile(d3base, 'fc9643_ud_5targ001', 'fc9643_ud_5targS001R0');
% 
% 
% files = { {[ud_im '1.dat'], [ud_im '2.dat'], [ud_im '3.dat'], [ud_im '4.dat'], [ud_im '5.dat']},...
%     {[ud_3targ '1.dat'], [ud_3targ '2.dat'], [ud_3targ '3.dat']},...
%     {[ud_5targ '1.dat'], [ud_5targ '2.dat'], [ud_5targ '3.dat'], [ud_5targ '4.dat'], [ud_5targ '5.dat']}};
% 
% ftemp = cat(2, files{1}, files{2}, files{3});

%% HG Shift

fname = sprintf('%s-%d-data.mat', subjid, numTargets);

if (exist(fname, 'file'))
    fprintf('using previously collated data: %s', fname);
    load (fname);
else
    shifts = [];
    tshifts = [];
    pres = [];
    tgts = [];
    epochs = [];
    ress = [];
    ts = [];
    fbs_late = [];
    
    for mfile = files{1}
        [~, sta, par] = load_bcidat(mfile{:});
        load(strrep(mfile{:}, '.dat', '_work.mat'));

        if (fs == 2400)
            for c = 1:size(hgs,1)
                hgs2(c,:) = decimate(hgs(c,:), 2);
            end

            hgs = hgs2; clear hgs2;

            sta.TargetCode = sta.TargetCode(1:2:end);
            sta.ResultCode = sta.ResultCode(1:2:end);
            sta.Feedback   = sta.Feedback(1:2:end);
            fs = 1200;
        end

        hgs(bads,:) = 1;

        rends = find(diff(double(sta.TargetCode)) > 0);
        rstarts = rends-par.ITIDuration.NumericValue * fs;

        tstarts = rends+1;
        tends = rends+par.PreFeedbackDuration.NumericValue * fs - 1;

    %     fstarts = rends+par.PreFeedbackDuration.NumericValue * fs;
        fstarts = rends+(par.PreFeedbackDuration.NumericValue) * fs;
        fends = rends+(par.PreFeedbackDuration.NumericValue+par.FeedbackDuration.NumericValue) * fs;

        bi = rstarts < 0 | fends > length(sta.TargetCode);

        rends(bi) = [];
        rstarts(bi) = [];

        tends(bi) = [];
        tstarts(bi) = [];

        fends(bi) = [];
        fstarts(bi) = [];

        goodFlags = flagGoodEpochs(hgs, rstarts, fends, [0 10]);

        fprintf('dropping %d of %d epochs for noise\n', length(goodFlags)-sum(goodFlags), length(goodFlags));

    %     figure, plot(hgs(1:96,:)');
    %     hold on; plot(3*(sta.TargetCode > 0), 'LineWidth', 2)
    %     pause;
    %     close;

        rends(~goodFlags) = [];
        rstarts(~goodFlags) = [];
        tends(~goodFlags) = [];
        tstarts(~goodFlags) = [];
        fends(~goodFlags) = [];
        fstarts(~goodFlags) = [];

        mshifts = zeros(size(hgs,1), length(rstarts));
        mtshifts = zeros(size(hgs,1), length(rstarts));
        mpres = zeros(size(hgs,1), length(rstarts));
        mts = zeros(size(hgs,1), length(rstarts));
        mfbs_late = zeros(size(hgs,1), length(rstarts));
        mepochs = zeros(size(hgs,1), length(rstarts), mode(fends-rstarts+1));

        for e_ctr = 1:length(rstarts)
            r = rstarts(e_ctr):rends(e_ctr);
            t = tstarts(e_ctr):tends(e_ctr);
            f = fstarts(e_ctr):fends(e_ctr);
            f_late = (fends(e_ctr)-fs):(fends(e_ctr));
            e = rstarts(e_ctr):fends(e_ctr);

            mshifts(:, e_ctr) = mean(hgs(:, f), 2) - mean(hgs(:, r), 2);
            mtshifts(:, e_ctr) = mean(hgs(:, t), 2) - mean(hgs(:, r), 2);
            mts(:, e_ctr) = mean(hgs(:,t), 2);
            mpres(:, e_ctr) = mean(hgs(:,r), 2);
            mfbs_late(:, e_ctr) = mean(hgs(:,f_late), 2);
            mepochs(:, e_ctr, :) = hgs(:,e); 
        end

        tgts = cat(1, tgts, sta.TargetCode(fstarts));
        ress = cat(1, ress, sta.ResultCode(fends));
        shifts = cat(2, shifts, mshifts);
        tshifts = cat(2, tshifts, mtshifts);
        pres = cat(2, pres, mpres);
        ts = cat(2, ts, mts);
        fbs_late = cat(2, fbs_late, mfbs_late);
        
        epochs = cat(2, epochs, mepochs);
    end

    save(fname);
end

%% display result
tgtList = unique(tgts)';

% this is a hack for one trial from fc, investigate!
if (length(tgtList)==4)
    tgtList(tgtList==4) = [];
end

hs = zeros(length(tgtList)+1, size(shifts,1));
ps = zeros(length(tgtList)+1, size(shifts,1));

[hs(1, :), ps(1, :)] = ttest(shifts', 0, 0.01, 'both');

for tgt = tgtList
    idx = find(tgt == tgtList);
    [hs(1+idx, :) ps(1+idx, :)] = ttest(shifts(:, tgts==tgt)', 0, 0.01, 'both');
end

% for c = 1:size(hs, 1) % all target types case
for c = 1 % up target only case
    shiftmeans = mean(shifts, 2);
    shiftmeans(Montage.BadChannels) = NaN;
    shiftmeans(bads) = NaN;
    shiftmeans(hs(c, :) == 0) = NaN;

    if (sum(~isnan(shiftmeans)))
        h1 = figure;
        PlotDotsDirect(subjid, Montage.MontageTrodes, shiftmeans, hemi, [-max(abs(shiftmeans)), max(abs(shiftmeans))], 20, 'recon_colormap');
        load('recon_colormap');
        colormap(cm);

        if c == 1
            title('all targets');
        else
            title(sprintf('target code %d', c-1));
        end

        colorbar;
    end
end

if (strcmp(subjid, 'fc9643'))
    interest = find(hs(1, :) == 1); % only looking at electrodes with relevant shift for all targets
elseif (strcmp(subjid, '38e116'))
    interest = find(hs(1, :) == 1);
%     interest = 1:64;
else
    error('unknown subject id used');
end

% %% display result (targeting shifts)
% tgtList = unique(tgts)';
% 
% % this is a hack for one trial from fc, investigate!
% if (length(tgtList)==4)
%     tgtList(tgtList==4) = [];
% end
% 
% hs = zeros(length(tgtList)+1, size(tshifts,1));
% ps = zeros(length(tgtList)+1, size(tshifts,1));
% 
% [hs(1, :), ps(1, :)] = ttest(tshifts', 0, 0.05 / size(tshifts, 1), 'right');
% 
% for tgt = tgtList
%     idx = find(tgt == tgtList);
%     [hs(1+idx, :) ps(1+idx, :)] = ttest(tshifts(:, tgts==tgt)', 0, 0.05 / size(tshifts, 1), 'right');
% end
% 
% % for c = 1:size(hs, 1) % all target types case
% for c = 1 % up target only case
%     shiftmeans = mean(shifts, 2);
%     shiftmeans(Montage.BadChannels) = NaN;
%     shiftmeans(bads) = NaN;
%     shiftmeans(hs(c, :) == 0) = NaN;
% 
%     if (sum(~isnan(shiftmeans)))
%         h1 = figure;
%         PlotDotsDirect(subjid, Montage.MontageTrodes, shiftmeans, hemi, [-max(abs(shiftmeans)), max(abs(shiftmeans))], 20, 'recon_colormap');
%         load('recon_colormap');
%         colormap(cm);
% 
%         if c == 1
%             title('all targets');
%         else
%             title(sprintf('target code %d', c-1));
%         end
% 
%         colorbar;
%     end
% end
% 
% if (strcmp(subjid, 'fc9643'))
%     interest = find(hs(1, :) == 1); % only looking at electrodes with downward shift for all targets
% elseif (strcmp(subjid, '38e116'))
%     interest = 1:64;
% else
%     error('unknown subject id used');
% end

%% show the time course for interesting electrodes
iepochs = epochs(interest,:,:);
t = -par.ITIDuration.NumericValue:1/fs:(par.PreFeedbackDuration.NumericValue+par.FeedbackDuration.NumericValue);

% dim = ceil(sqrt(length(interest)));
% h2 = figure;
% 
% colors = 'rgbcmykr';
% 
% for c = 1:length(interest)
%     if (~ismember(interest(c), bads))
%         subplot(dim, dim, c);
% 
%         for d = 1:size(hs, 1) % all target types case
%             if d == 1
%                 plotWSE(t, squeeze(iepochs(c, :, :))', colors(d), 0.2, [colors(d) '-']); hold on;
%             else
%                 tgt = tgtList(d-1);
% 
%                 plotWSE(t', squeeze(iepochs(c, tgts==tgt, :) + (d-1)*.25)', colors(d), 0.2, [colors(d) '-']);
%             end
%         end
% 
%         title(trodeNameFromMontage(interest(c), Montage));
%         ylim([.5 1 + size(hs, 1)*0.25]);
%     end
% end

%% whisker plots by trial type

dim = ceil(sqrt(length(interest)));
h3 = figure;

for c = 1:length(interest)
    if (~ismember(interest(c), bads))
        subplot(dim, dim, c);

        mus = zeros(length(tgtList)+1, 1);
        ses = zeros(length(tgtList)+1, 1);

        mus(1) = mean(shifts(interest(c), :), 2);
        ses(1) = sem(shifts(interest(c), :), 2);

        for tgt = tgtList
            d = find(tgt == tgtList)+1;

            mus(d) = mean(shifts(interest(c), tgts == tgt), 2);
            ses(d) = sem(shifts(interest(c), tgts == tgt), 2);
        end

        barweb(mus, ses);

        title(sprintf('%s', trodeNameFromMontage(interest(c), Montage)));
        ylabel('shift');
    %     xlabel('target type');
    end
end
 
% %% whisker plots by trial type
% 
% dim = ceil(sqrt(length(interest)));
% h3 = figure;
% 
% for c = 1:length(interest)
%     if (~ismember(interest(c), bads))
%         subplot(dim, dim, c);
% 
%         mus = zeros(length(tgtList)+1, 1);
%         ses = zeros(length(tgtList)+1, 1);
% 
%         mus(1) = mean(tshifts(interest(c), :), 2);
%         ses(1) = sem(tshifts(interest(c), :), 2);
% 
%         for tgt = tgtList
%             d = find(tgt == tgtList)+1;
% 
%             mus(d) = mean(tshifts(interest(c), tgts == tgt), 2);
%             ses(d) = sem(tshifts(interest(c), tgts == tgt), 2);
%         end
% 
%         barweb(mus, ses);
% 
%         title(sprintf('%s', trodeNameFromMontage(interest(c), Montage)));
%         ylabel('tshift');
%     %     xlabel('target type');
%     end
% end
% 
% 
% %% let's compare performance
% hits = tgts == ress;
% miss = tgts ~= ress;
% 
% hitshifts = shifts(interest, hits);
% missshifts = shifts(interest, miss);
% 
% dim = ceil(sqrt(length(interest)));
% h4 = figure;
% 
% for c = 1:length(interest)
%     if (~ismember(interest(c), bads))
%         subplot(dim, dim, c);
% 
%         h = squeeze(hitshifts(c, :));
%         m = squeeze(missshifts(c, :));
% 
%     %     if (c==15)
%     %         fprintf('%s\n',trodeNameFromMontage(interest(c), Montage));
%     %         x = 5;
%     %     end    
% 
%         [~, p] = ttest2(h,m);
%         barweb([mean(h) mean(m)], ...
%             [sem(h') sem(m')], .8, {'a','b','c'});
% 
%         title(sprintf('%s (%f)', trodeNameFromMontage(interest(c), Montage), p));
%         ylabel('tshift');
%         xlabel('hits / misses');
%     end
% end
% 
% %% let's compare performance as a function of pre val
% hits = tgts == ress;
% miss = tgts ~= ress;
% 
% hitpres = pres(interest, hits);
% misspres = pres(interest, miss);
% 
% dim = ceil(sqrt(length(interest)));
% h5 = figure;
% 
% for c = 1:length(interest)
%     if (~ismember(interest(c), bads))
%         subplot(dim, dim, c);
% 
%         h = squeeze(hitpres(c, :));
%         m = squeeze(misspres(c, :));
% 
%     %     if (c==15)
%     %         fprintf('%s\n',trodeNameFromMontage(interest(c), Montage));
%     %         x = 5;
%     %     end    
% 
%         [~, p] = ttest2(h,m);
%         barweb([mean(h) mean(m)], ...
%             [sem(h') sem(m')], .8, {'a','b','c'});
% 
%         title(sprintf('%s (%f)', trodeNameFromMontage(interest(c), Montage), p));
%         ylabel('pre');
%         xlabel('hits / misses');
%     end
% end

% %% save all the figures
% 
% if (exist('h1','var'))
%     figure(h1);
%     maximize;
%     if (hemi == 'r')
%         view(90,0);
%         SaveFig(odir, [prefix 'dots-lat'], 'png');
%         view(270,0);
%         SaveFig(odir, [prefix 'dots-med'], 'png');
%     else
%         view(270,0);
%         SaveFig(odir, [prefix 'dots-lat'], 'png');
%         view(90,0);
%         SaveFig(odir, [prefix 'dots-med'], 'png');
%     end
% end
% 
% figure(h2);
% maximize;
% saveas(h2, fullfile(odir, [prefix 'timeseries.png']), 'png');
% 
% figure(h3);
% maximize;
% saveas(h3, fullfile(odir, [prefix 'bytarget.eps']), 'eps');
% 
% figure(h4);
% maximize;
% saveas(h4, fullfile(odir, [prefix 'byperformance.eps']), 'eps');
% 
% figure(h5);
% maximize;
% saveas(h5, fullfile(odir, [prefix 'byperformancepre.eps']), 'eps');
% 

%% time series plots

for cc = interest
    chan = find(interest == cc)

    iepochsSmooth = squeeze(iepochs(chan, :, :));

    for c = 1:size(iepochsSmooth, 1)
        iepochsSmooth(c, :) = GaussianSmooth(iepochsSmooth(c, :), 250);
    end

    m = max(unique(tgts))-1;
    
    midhits = tgts>=2&tgts<=m&tgts==ress;
    midmiss = tgts>=2&tgts<=m&tgts~=ress;

    outhits = (tgts<2|tgts>m)&tgts==ress;
    outmiss = (tgts<2|tgts>m)&tgts~=ress;

    figure;
    plotWSE(t', iepochsSmooth(outhits, :)', 'b', .5, 'b-', 2);
    hold on;
    plotWSE(t', iepochsSmooth(outmiss, :)', 'g', .5, 'g-', 2);
    plotWSE(t', iepochsSmooth(midhits, :)', 'y', .5, 'y-', 2);
    plotWSE(t', iepochsSmooth(midmiss, :)', 'r', .5, 'r-', 2);

    % figure, plot(t', GaussianSmooth(mean(squeeze(iepochs(chan, midhits, :)),1),250));
    % hold on;
    % plot(t', GaussianSmooth(mean(squeeze(iepochs(chan, midmiss, :)),1),250),'r');
    % plot(t', GaussianSmooth(mean(squeeze(iepochs(chan, outhits, :)),1),250),'g');
    % plot(t', GaussianSmooth(mean(squeeze(iepochs(chan, outmiss, :)),1),250),'k');

    hl = legend('imprecision / hit', 'imprecision / miss', 'precision / hit', 'precision / miss', 'Location', 'Northwest');
    xlabel('time (s)', 'FontSize', 16);
    ylabel('HG power (AU)', 'FontSize', 16);
    title('Example average time series of BCI trial', 'FontSize', 16);%    title(trodeNameFromMontage(cc, Montage))
    set(gca, 'FontSize', 14);
    
    axis tight
    
    vline(0, 'k')
    vline(2, 'k--')    
    
    
    
    if (strcmp(subjid, 'fc9643') && cc == 20)
        fprintf('SAVE THE FIGURE');
        return;
        % SaveFig(pwd, 'exampletrace', 'tif')
    end
end

%% do bar plots of the interesting electrodes
if (strcmp(subjid, '38e116'))
    perimotorinterest = [25 26];
%     perimotorinterest = [9 10 11 12 17 18 19 20 25 26 27 28 33 34 35 36 41 42 43 44];
%     perimotorinterest= 33:64;
    subcode = 'S2';
else
    perimotorinterest = [5 24]
    subcode = 'S1';
end

temp = ts(perimotorinterest, :);

means = [mean(temp(:,outhits),2) mean(temp(:, outmiss),2) mean(temp(:, midhits),2) mean(temp(:, midmiss),2)];
sems  = [ sem(temp(:,outhits),2)  sem(temp(:, outmiss),2)  sem(temp(:, midhits),2)  sem(temp(:, midmiss),2)];  

trodeNames = {};
for c = 1:length(perimotorinterest)
    trodeNames{c} = trodeNameFromMontage(perimotorinterest(c), Montage);
end

figure;
barweb(means, sems, 1, trodeNames, sprintf('Pericontrol, pre-feedback HG power, %s', subcode), 'Electrode', ...
    'HG Power (AU)', cm, []);

hs=[]; ps=[];

[h, p] = ttest2(temp(:,outhits)', temp(:, outmiss|midhits|midmiss)')
    
SaveFig(pwd, sprintf('%s-pericontrol', subjid), 'eps');

%% do bar plots of the interesting electrodes
if (strcmp(subjid, 'fc9643'))
    
    smapfcinterest = [20 86 92 94];
%     tempi = iepochs(smapfcinterest, :, 
    subcode = 'S1';

    temp = fbs_late(smapfcinterest, :);

    means = [mean(temp(:,outhits),2) mean(temp(:, outmiss),2) mean(temp(:, midhits),2) mean(temp(:, midmiss),2)];
    sems  = [ sem(temp(:,outhits),2)  sem(temp(:, outmiss),2)  sem(temp(:, midhits),2)  sem(temp(:, midmiss),2)];  

    trodeNames = {};
    for c = 1:length(smapfcinterest)
        trodeNames{c} = trodeNameFromMontage(smapfcinterest(c), Montage);
    end

    figure;
    barweb(means, sems, 1, trodeNames, sprintf('SMA/PFC, during-feedback HG power, %s', subcode), 'Electrode', ...
        'HG Power (AU)', cm, []);

    hs=[]; ps=[];

    [h, p] = ttest2(temp(:,outhits)', temp(:, outmiss|midhits|midmiss)')

    SaveFig(pwd, sprintf('%s-smapfc', subjid), 'eps');

end
