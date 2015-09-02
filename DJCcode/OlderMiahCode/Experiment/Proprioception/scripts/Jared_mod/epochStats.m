%% perform epoch-based statistical analyses

function [HGSigs, BetaSigs, HGRSAs, BetaRSAs, HGSigsp, BetaSigsp, HGCi1, HGCi2, BetaCi1, BetaCi2, HGStats, BetaStats]...
    = epochStats(activityHGs, activityBetas, restHGs, restBetas, activities, numChans)

ptarg = 0.05 / numChans; % p-value target, divided by number of channels (Bonferroni correction?)

HGSigs = zeros(length(activities), numChans);% == 1; % force boolean type
HGRSAs = zeros(length(activities), numChans);
HGSigsp = zeros(length(activities), numChans);
HGCi1 = zeros(length(activities), numChans);
HGCi2 = zeros(length(activities), numChans);
HGStats = double (zeros(length(activities), numChans));

BetaSigs = zeros(length(activities), numChans);% == 1; % force boolean type
BetaRSAs = zeros(length(activities), numChans);
BetaSigsp = zeros(length(activities), numChans);
BetaCi1 = zeros(length(activities), numChans);
BetaCi2 = zeros(length(activities), numChans);
BetaStats = double(zeros(length(activities), numChans));

for activityIdx = 1:length(activities)
    tempHGs = activityHGs{activityIdx};
    tempBetas = activityBetas{activityIdx};
        
    [HGSigs(activityIdx,:), HGSigsp(activityIdx,:), tempHGCi, tempHGStats] = ttest2(restHGs, tempHGs, ptarg, 'left', 'unequal', 1); %runs t-test and puts into HGSigs (boolean for significant channels). JDO- Note: left sided, assuming unequal variances, on the first dimension 
    HGStats (activityIdx,:) = tempHGStats.tstat (1,:);
    HGCi1 (activityIdx,:) = tempHGCi (1, :);
    HGCi2 (activityIdx,:) = tempHGCi (2, :);
    
    [BetaSigs(activityIdx,:), BetaSigsp(activityIdx,:), tempBetaCi, tempBetaStats] = ttest2(restBetas, tempBetas, ptarg,'right', 'unequal', 1);
    BetaStats (activityIdx,:) = tempBetaStats.tstat(1,:);
    BetaCi1 (activityIdx,:) = tempBetaCi (1, :);
    BetaCi2 (activityIdx,:) = tempBetaCi (2, :);
    
    HGRSAs(activityIdx,:) = signedSquaredXCorrValue(tempHGs, restHGs, 1); %calcualtions for RSA values..JDO- need to go through signedSquaredXCorrValue.m to learn calculation of RSA...not commented. 
    BetaRSAs(activityIdx,:) = signedSquaredXCorrValue(tempBetas, restBetas, 1);
end

if (sum(sum(isnan(HGSigs))) || sum(sum(isnan(BetaSigs))))
    warning('forcing NaNs to zero');
    HGSigs (isnan(HGSigs)) = 0;
    BetaSigs (isnan(BetaSigs)) = 0;
end

HGSigs = HGSigs == 1; % make boolean
BetaSigs = BetaSigs == 1; % make boolean