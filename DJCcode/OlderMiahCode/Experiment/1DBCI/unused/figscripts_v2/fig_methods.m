%% bit by bit, this script generates the methods figure(s)

outputDir = [myGetenv('output_dir') '\remoteAreas\AllPower\SFN2012'];
TouchDir(outputDir);


%% example brain
PlotCortex('26cb98');
PlotElectrodes('26cb98', {'Grid'})
set(gcf, 'Color', [1 1 1]);
view(90,0);

%% more
cd([myGetenv('matlab_devel_dir') '\Experiment\1DBCI']);

files = {'d:\research\subjects\\fc9643\D2\fc9643_ud_im_t001\fc9643_ud_im_tS001R01.dat', ...
'd:\research\subjects\\fc9643\D2\fc9643_ud_im_t001\fc9643_ud_im_tS001R02.dat', ...
'd:\research\subjects\\fc9643\D2\fc9643_ud_im_t001\fc9643_ud_im_tS001R03.dat', ...
'd:\research\subjects\\fc9643\D2\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R01.dat', ...
'd:\research\subjects\\fc9643\D2\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R02.dat', ...
'd:\research\subjects\\fc9643\D2\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R03.dat', ...
'd:\research\subjects\\fc9643\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R01.dat', ...
'd:\research\subjects\\fc9643\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R03.dat', ...
'd:\research\subjects\\fc9643\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R04.dat', ...
'd:\research\subjects\\fc9643\D3\fc9643_ud_im_t001\fc9643_ud_im_tS001R05.dat', ...
'd:\research\subjects\\fc9643\D3\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R01.dat', ...
'd:\research\subjects\\fc9643\D3\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R02.dat', ...
'd:\research\subjects\\fc9643\D4\fc9643_ud_im_t001\fc9643_ud_im_tS001R01.dat', ...
'd:\research\subjects\\fc9643\D4\fc9643_ud_mot_t001\fc9643_ud_mot_tS001R01.dat' ...
};

control = 24;
subject = 'fc9643';


%% make task, raw, and hg plots
tcs; % load color theme

re = theme_colors(red,:);
bl = theme_colors(blue, :);
gr = theme_colors(7, :);
pu = theme_colors(8, :);
lb = theme_colors(9, :);
or = theme_colors(10, :);

[signals, states, parameters] = load_bcidat(files{5});
load(strrep(files{5}, '.dat', '_montage.mat'));
fs = parameters.SamplingRate.NumericValue;

signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, double(signals));
csig = signals(:,control);
csigbp = bandpass(csig, 70, 200, fs, 4);
csighilb = hilbAmp(csig, [70 200], fs); 
csighilbpwr = hilbAmp(csig, [70 200], fs).^2;
reppwr = exp(GaussianSmooth(log(csighilbpwr), fs*2));

paradigm = double(states.TargetCode) .* double(states.Feedback ~= 0);

t = (1:length(csig)) / fs;
tmin = 72;
tmax = 99;

t_sub = t(t > tmin & t < tmax);
p_sub = paradigm(t > tmin & t < tmax);

figure;

plot(t_sub,p_sub,'k'); hold on;
% plot(t_sub(p_sub==1),p_sub(p_sub==1),'Color', re,'LineWidth',2); hold on;
% plot(t_sub(p_sub==2),p_sub(p_sub==2),'Color', bl,'LineWidth',2);


plot(t(t > tmin & t < tmax),csig(t > tmin & t < tmax) / max(csig(t > tmin & t < tmax)) - 1.5, 'Color',pu, 'LineWidth', 1);
plot(t(t > tmin & t < tmax),reppwr(t > tmin & t < tmax) / max(reppwr(t > tmin & t < tmax)) - 4, 'Color',gr, 'LineWidth', 1);
plot(t(t > tmin & t < tmax),csigbp(t > tmin & t < tmax) / max(csigbp(t > tmin & t < tmax)) - 6.5, 'Color',or, 'LineWidth', 1);
% plot(t(t > tmin & t < tmax),csighilb(t > tmin & t < tmax) / max(csighilb(t > tmin & t < tmax)) - 6.5, 'k--', 'LineWidth', 2);


ylim([-8 2.5]);
%% make powers figures

% common across all remote areas analysis scripts
subjects = {
    '26cb98'
    '04b3d5'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };

points = [
    80
    46
    26
    47
    53
    57
    41
    ];

for c = 4%1:length(subjects)
    load(['AllPower.m.cache\' subjects{c} '.mat']);

    up = 1;
    down = 2;
    
    smoothUp = GaussianSmooth(epochZs(controlChannel, targetCodes == up), 10)';
    smoothDown = GaussianSmooth(epochZs(controlChannel, targetCodes == down), 10)';
    
    smoothUpStd = runningSD(epochZs(controlChannel, targetCodes == up), 10);
    smoothDownStd = runningSD(epochZs(controlChannel, targetCodes == down), 10);
    
    ups = find(targetCodes == up);
    downs = find(targetCodes == down);

    figure;
    plot(ups, epochZs(controlChannel, targetCodes == up), 'r.', 'MarkerSize', 15); hold on;
    plot(ups, smoothUp, 'r', 'LineWidth', 2); hold on;
    plot(ups, smoothUp+smoothUpStd, 'r:', 'LineWidth', 2);
    plot(ups, smoothUp-smoothUpStd, 'r:', 'LineWidth', 2);
    
    plot(ups, epochZs(controlChannel, targetCodes == down), 'b.', 'MarkerSize', 15); hold on;
    plot(downs, smoothDown, 'b', 'LineWidth', 2);
    plot(downs, smoothDown+smoothDownStd, 'b:', 'LineWidth', 2);
    plot(downs, smoothDown-smoothDownStd, 'b:', 'LineWidth', 2);
    
    plot([points(c), points(c)], [-1 4], 'k', 'LineWidth', 2);
    
    preCodes = targetCodes(1:points(c));
    postCodes = targetCodes(points(c)+1:end);
    
    preZs = epochZs(:, 1:points(c));
    postZs = epochZs(:, points(c)+1:end);
    
    preupZs = preZs(:, preCodes == up);
    predownZs = preZs(:, preCodes == down);
    
    postupZs = postZs(:, postCodes == up);
    postdownZs = postZs(:, postCodes == down);

    [allrsas, allh] = signedSquaredXCorrValue(postZs, preZs, 2, 0.05/size(epochZs,1));
    allrsas(allh == 0) = NaN;
    
    [uprsas, uph] = signedSquaredXCorrValue(postupZs, preupZs, 2, 0.05/size(epochZs,1));
    uprsas(uph == 0) = NaN;
    
    [downrsas, downh] = signedSquaredXCorrValue(postdownZs, predownZs, 2, 0.05/size(epochZs,1));
    downrsas(downh == 0) = NaN;
end
 
% plot(79, 4.251, 'o', 'Color', [139/255 0 204/255], 'MarkerSize', 20, 'LineWidth', 2);


%% make comparison

ctlpreup = preupZs(controlChannel,:);
ctlpostup = postupZs(controlChannel,:);

ctlpredn = predownZs(controlChannel,:);
ctlpostdn = postdownZs(controlChannel,:);

barweb([mean(ctlpreup) mean(ctlpredn); mean(ctlpostup) mean(ctlpostdn)], ...
       [grpstats(ctlpreup, [], 'sem') grpstats(ctlpredn, [], 'sem'); grpstats(ctlpostup, [], 'sem') grpstats(ctlpostdn, [], 'sem')], ...
       1.5, {'pre','post'}, 'pre-post power comparison', [], 'z-scored HG power', ...
       [1 0 0; 0 0 1], 'none', {'up','down'},1);

%%
epochZs = [];
restZs = [];
targetCodes = [];
resultCodes = [];

badchans = [];

for recnum = 1:length(ds.recs)
    fprintf('processing recording %d of %d\n', recnum, length(ds.recs));

    if(recnum == 1 && strcmp(dsFile, 'ds/fc9643_ud_mot_t_ds.mat')  == 1) 
        controlChannel = 23;
        warning('little hack here');
    elseif (strcmp(dsFile, 'ds/fc9643_ud_mot_t_ds.mat')  == 1)
        controlChannel = 24;
    end

    if(strcmp(subject, '26cb98') == 1)
        badchans = union(badchans, 82);
        warning('little hack here');
    end

    [signals, states, parameters] = load_bcidat([ds.recs(recnum).dir '\' ds.recs(recnum).file]);
    load([ds.recs(recnum).dir '\' ds.recs(recnum).montage]);

    badchans = union(badchans, Montage.BadChannels);

    parameters = CleanBCI2000ParamStruct(parameters);

    signals = double(signals);

    if (size(signals,2) == 64)
        signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
        signals = signals(:, 1:sum(Montage.Montage));
    else
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    end

    cRange = getControlRange(parameters);

        fprintf('  Control channel: %i\n', controlChannel);
        fprintf('  Control range: [%f-%f] Hz\n', min(cRange), max(cRange));

    signals = NotchFilter(signals, [60 120 180], parameters.SamplingRate);
    signals = BandPassFilter(signals, [min(cRange) max(cRange)], parameters.SamplingRate, 6);
    signals = abs(hilbert(signals));

    [restStarts, restEnds] = getEpochs(states.TargetCode, 0);
    l = min(length(restStarts),length(restEnds));
    restStarts = restStarts(2:l); % ditch that first rest epoch
    restEnds   = restEnds(2:l);
    clear l;

    [runStarts, runEnds] = getEpochs((states.TargetCode & states.Feedback) ~= 0, 1);
    l = min(length(runStarts),length(runEnds));
    runStarts = runStarts(1:l);
    runEnds   = runEnds(1:l);
    clear l;

    epochSignal = getEpochSignal(signals, runStarts, runEnds);
    restSignal = getEpochSignal(signals, restStarts, restEnds);

    sigavs = squeeze(mean(epochSignal, 1));
    restavs = squeeze(mean(restSignal, 1));
%         reststds = std(restSignals, 1);

    % My Method, see notes from 2/1/12 in notebook
    epochZ = ((sigavs' - repmat(mean(restavs', 1), size(sigavs', 1), 1)) ./ repmat(std(restavs', 1), size(sigavs', 1), 1))';    
%     epochZ = (sigavs - repmat(mean(restavs, 2), 1, size(sigavs, 2))) ./ repmat(std(restavs, 0, 2), 1, size(sigavs, 2));
    restZ = ((restavs' - repmat(mean(restavs', 1), size(restavs', 1), 1)) ./ repmat(std(restavs', 1), size(restavs', 1), 1))';    
%     restZ  = (restavs - repmat(mean(restavs, 2), 1, size(restavs, 2))) ./ repmat(std(restavs, 0, 2), 1, size(restavs, 2)); 

    % Tim's Method, see notes from 2/1/12 in notebook
%     scores = (sigavs - mean(restavs)) / mean(reststds);

    targetCodes = [targetCodes; states.TargetCode(runStarts)];
    resultCodes = [resultCodes; states.ResultCode(runEnds + 1)];
    

    epochZs = [epochZs, epochZ];
    restZs = [restZs, restZ];
end

% clearvars -except Montage badchans cRange controlChannel ds dsFile epochZs outputDir restZs resultCodes targetCodes side subject cacheFile
% save(cacheFile);

%%

fprintf('  plotting time variant powers: %s\n', subject);

upscores = allscores(alltargets == up, :);
downscores = allscores(alltargets == down, :);

upcontrol = upscores(:, controlChannel);
downcontrol = downscores(:, controlChannel);

swin = 15;

up = 1;
down = 2;

dim = ceil(sqrt(size(allscores, 2)));
figure;

labels = getLabelsFromMontage(Montage, 1:size(allscores, 2));


% locate the trial with maximum power difference
upscores = allscores(alltargets == up, controlChannel);
downscores = allscores(alltargets == down, controlChannel);
difference = interpDifference(GaussianSmooth(upscores, swin), alltargets == up, GaussianSmooth(downscores, swin), alltargets == down);
[~, divIdx] = max(difference);

if (strcmp(subject, '26cb98') == 1)
    divIdx = 65;
    warning('BIG hack here');
end

for chan = 1:size(allscores, 2)
    if (sum(badchans == chan) == 0)
        ax(chan) = subplot(dim, dim, chan);

        upscores = allscores(alltargets == up, chan);
        downscores = allscores(alltargets == down, chan);

        upidxs = find(alltargets == up);
        downidxs = find(alltargets == down);

        results = allresults == alltargets;
        upresults = allresults(alltargets == up) == up;
        downresults = allresults(alltargets == down) == down;

    %     figure;
    %     plot(upidxs, upscores, 'r*'); hold on;
        hold on;
    %     plot(downidxs, downscores, 'b*');

        plot(upidxs, GaussianSmooth(upscores, swin), 'r');
        plot(downidxs, GaussianSmooth(downscores, swin), 'b');

    %     plot(find(results == 0), allscores(results == 0, chan), 'ks');

        difference = interpDifference(GaussianSmooth(upscores, swin), alltargets == up, GaussianSmooth(downscores, swin), alltargets == down);
        differences(:, chan) = difference;

        plot(difference, 'k');

        if (chan == controlChannel)
%             [val, differenceIdx] = max(difference);
%             plot(differenceIdx, val, 'gd');

            plot(divIdx, difference(divIdx), 'gd');
        end

        set(gca, 'XTickLabel', {});
        set(gca, 'YTickLabel', {});
        axis tight;
        set(gca, 'ylim', [-5 5]);
        plot([divIdx divIdx], get(gca, 'YLim'), 'g');

        if (chan == controlChannel)
            title(labels{chan}, 'color', 'r');
        else
            title(labels{chan});
        end

        if (chan == size(allscores, 2))
            legend('up','down','difference', 'Location', 'EastOutside');
        end
    else
        differences(:, chan) = 0;
    end
    
end

mtit(sprintf('Time Variant Powers: %s', subject), 'xoff', 0, 'yoff', .03);


