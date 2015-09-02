% behavioral Analysis
cd ([ myGetenv('matlab_devel_dir') 'Experiment\1DBCI']);

% load ds/26cb98_ud_im_t_ds.mat
% load ds/38e116_ud_mot_h_ds.mat % *
% load ds/4568f4_ud_mot_t_ds.mat
load ds/30052b_ud_im_t_ds.mat % * only one where gains don't cause problems
% load ds/fc9643_ud_mot_t_ds.mat % *

% not from original datasets
% load ds/fc9643_ud_im_t_ds.mat % *

pathsNorm = [];
targets = [];

uphitratios = [];
downhitratios = [];

upscores = [];
downscores = [];
upscoreses = [];
downscoreses = [];
    
downmeans = [];
downsds   = [];
downses   = [];
upmeans   = [];
upsds     = [];
upses     = [];

for recnum = 1:length(ds.recs)
    [signals, states, parameters] = load_bcidat([ds.recs(recnum).dir '\' ds.recs(recnum).file]);
    load([ds.recs(recnum).dir '\' ds.recs(recnum).montage]);
    
    parameters = CleanBCI2000ParamStruct(parameters);

    fprintf('normalizer settings: \n');
    fprintf('  adaptation: %d\n', parameters.Adaptation);
    fprintf('  gains     : %f\n', parameters.NormalizerGains);
    fprintf('  offsets   : %f\n', parameters.NormalizerOffsets);
%     parameters.TransmitChList
    fprintf('\n');
    
    cpy = fixYPos(states.CursorPosY);
    
    height = double(parameters.WindowHeight);
    fb = double(states.Feedback);

    yPath = max(min(cpy, height), 0);
    yPathNorm = yPath / height;
    yPathNorm = (yPathNorm - 0.5) * 2; % normalize to [-1 1]
    yPathNorm = yPathNorm / parameters.NormalizerGains(1);
    
    fbEvents = [0; diff(fb)];
    fbOnset = find(fbEvents == 1);
    fbOffset = find(fbEvents == -1);
    
    if length(fbOnset) > length(fbOffset)
        fbOnset = fbOnset(1:length(fbOffset));
    end
    
    pathsNorm = zeros(fbOffset(1)-fbOnset(1), length(fbOnset));
    
    pathT = (0:(fbOffset(1)-fbOnset(1)-1))'/parameters.SamplingRate;
    
    for c = 1:length(fbOnset)
        pathsNorm(:,c) = yPathNorm(fbOnset(c):(fbOffset(c)-1)); 
        dydt = [0; diff(pathsNorm(:,c))];
        
%         lastHigh = find(pathsNorm(:,c) < 1, 1, 'last');
%         lastLow  = find(pathsNorm(:,c) > -1, 1, 'last');
%         last = min(lastHigh, lastLow);
%         
%         slopes(c) = mean(dydt(1:last));
        
        mmax = 1 / parameters.NormalizerGains(1);
        
        highSaturation = find(pathsNorm(:,c) <  mmax, 1, 'last');
        lowSaturation  = find(pathsNorm(:,c) > -mmax, 1, 'last');
        
        saturation = min(highSaturation, lowSaturation);
        
        slopes(c) = mean(dydt(1:saturation));
        
    end
  
    targets = states.TargetCode(fbOnset);
    results = states.ResultCode(fbOffset);

%     vals = mean(pathsNorm);
%     modifiers = (double(targets) - 1.5) * 2;
%     mvals = vals .* modifiers';
%     scores = mvals * 2;
       
%     figure;
%     
%     for c = 1:length(fbOnset)
%         if (targets(c) == 2)
%             colorspec = 'b';
%         else
%             colorspec = 'r';
%         end
%         
%         plot(pathT, pathsNorm(:, c), colorspec);
% %         ylim([-1 1]);
%         fit = (1:length(pathsNorm(:,c))) * slopes(c);
% %         fit = max(min((1:length(pathsNorm(:,c))) * slopes(c) + 0.5, 1), 0);
%         hold on;
%         plot(pathT, fit, '-', 'Color', colorspec, 'LineWidth', 2);
%         
%         pause(.1);
%         
%     end

        % down targets
        
    temptgt = targets(targets == 2);
    tempres = results(targets == 2);
    
    uphitratio = sum(temptgt == tempres) / length(temptgt);
    uphitratios = [uphitratios uphitratio];
    
    temptgt = targets(targets == 1);
    tempres = results(targets == 1);
    
    downhitratio = sum(temptgt == tempres) / length(temptgt);
    downhitratios = [downhitratios downhitratio];
    
    downslopes = slopes(targets == 1);
    upslopes = slopes(targets == 2);

    downmeans = [downmeans mean(downslopes)];
    downsds   = [downsds   std(downslopes)];
    downses   = [downses   std(downslopes) / sqrt(length(downslopes))];

    upmeans   = [upmeans   mean(upslopes)];
    upsds     = [upsds     std(upslopes)];
    upses     = [upses     std(upslopes) / sqrt(length(upslopes))];

%     upscores = [upscores mean(scores(targets == 2))];
%     downscores = [downscores mean(scores(targets == 1))];
%     upscoreses = [upscoreses std(scores(targets == 2)) / sqrt(length(scores(targets == 2)))];
%     downscoreses = [downscoreses std(scores(targets == 1)) / sqrt(length(scores(targets == 1)))];
    
%     plot(pathT, pathsNorm(:, targets==1), 'b');
%     hold on;
%     plot(pathT, pathsNorm(:, targets==2), 'r');
%     
%     title(sprintf('run %d', recnum));
        
end

figure;
subplot(221);
errorbar(upmeans, upses);
title('up slopes');

subplot(222);
plot(uphitratios); hold on;
plot(uphitratios, '*');
title('up hit ratios');

% subplot(233);
% errorbar(upscores, upscoreses);
% title('up scores');

subplot(223);
errorbar(downmeans, downses);
title('down slopes');

subplot(224);
plot(downhitratios); hold on;
plot(downhitratios, '*');
title('down hit ratios');

% subplot(236);
% errorbar(downscores, downscoreses);
% title('down scores');
