% demonstrate overall interest in the task,
%   look at zscores during task phases (rest, targeting, fb, reward)
%   for all areas recorded and show statistically significant RSA values
%   (bonferroni corrected for the number of electrodes in the recording)
%   
%   this is obviously a separate analysis for up targets and down targets

%% load cache file
dsFile = 'cache\04b3d5_ud_im_t_ds.mat.cache.mat';
load(dsFile);
%% do statistical analyses
pTarget = 0.01;% / size(restScores, 2); % bonf corrected

upPsRest = ttest2(restScores(tgtCodes == 1,:), restScores(tgtCodes == 2,:), pTarget, 'both', 'unequal', 1);
% upRSARest = signedSquaredXCorrValue(restScores(tgtCodes == 1,:), restScores(tgtCodes == 1,:), 1);

upPsTgt = ttest2(tgtScores(tgtCodes == 1,:), tgtScores(tgtCodes == 2,:), pTarget, 'both', 'unequal', 1);
% upRSATgt = signedSquaredXCorrValue(tgtScores(tgtCodes == 1,:), restScores(tgtCodes == 1,:), 1);

upPsFb = ttest2(fbScores(tgtCodes == 1,:), fbScores(tgtCodes == 2,:), pTarget, 'both', 'unequal', 1);
% upRSAFb = signedSquaredXCorrValue(fbScores(tgtCodes == 1,:), restScores(tgtCodes == 1,:), 1);

upPsReward = ttest2(rewardScores(tgtCodes == 1,:), rewardScores(tgtCodes == 2,:), pTarget, 'both', 'unequal', 1);
% upRSAReward = signedSquaredXCorrValue(rewardScores(tgtCodes == 1,:), restScores(tgtCodes == 1,:), 1);

%% plot results
% figure;
% 
% for c = 1:64
%     subplot(221);
%     plot(find(tgtCodes==1),restScores(tgtCodes==1,c),'r.');
%     hold on;
%     plot(find(tgtCodes==2),restScores(tgtCodes==2,c),'b.');
%     title('rest');
%     
%     subplot(222);
%     plot(find(tgtCodes==1),tgtScores(tgtCodes==1,c),'r.');
%     hold on;
%     plot(find(tgtCodes==2),tgtScores(tgtCodes==2,c),'b.');
%     title('tgt');
%     
%         subplot(223);
%     plot(find(tgtCodes==1),fbScores(tgtCodes==1,c),'r.');
%     hold on;
%     plot(find(tgtCodes==2),fbScores(tgtCodes==2,c),'b.');
%     title('fb');
%     
%     subplot(224);
%     plot(find(tgtCodes==1),rewardScores(tgtCodes==1,c),'r.');
%     hold on;
%     plot(find(tgtCodes==2),rewardScores(tgtCodes==2,c),'b.');
%     title('reward');
%     
%     fprintf('channel %d\n', c);
%     drawnow;
%     pause;
%     clf;
% end
