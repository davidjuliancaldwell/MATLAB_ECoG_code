%% define constants
addpath ./functions
tcs;
Z_Constants;

% %% delete the files from a previous run
% 
% for c = 1:length(SIDS);
%     subjid = SIDS{c};
%     subcode = SUBCODES{c};
% 
%     metaFilename = fullfile(META_DIR, sprintf('performance-%s.mat', subcode));
%     
%     if (exist(metaFilename, 'file'))
%         delete(metaFilename);
%     end
% end

%% do the analyses for the performance figure

FORCE = true;

metaFilename = fullfile(META_DIR, 'performance.mat');

% % if you want to start from scratch, uncomment this line
% delete (metaFilename);

if (FORCE || ~exist(metaFilename, 'file'))
    % this is the matrix that we will store all of the behavioral results in
    % indices are as follows
    %  1 - subject index
    %  2 - run
    %  3 - trial
    %  4 - target
    %  5 - result
    %  6 - mean time to target (NaN if fail)
    %  7 - integrated squared error, calculated workspaceHeight*seconds
    %  8 - ending side (1 if correct - ie same side as target, 0 if incorrect)
    
    behavior = [];

    for c = 1:length(SIDS);
        subjid = SIDS{c};
        subcode = SUBCODES{c};

        fprintf ('processing %s: \n', subcode);

        [files, ~, ~, ~, isbias] = goalDataFiles(subjid);

        % don't look at the files where biasing was occuring
%         files(isbias==1) = [];
        
        nextTrialNum = 1;

        for fileIdx = 1:length(files)
            fprintf('  file %d of %d\n', fileIdx, length(files));            
            [targets, results, time, ise, endSide] = extractGoalBCIPerformance(files{fileIdx});

            subjectIndices = c * ones(size(targets));
            runIndices = fileIdx * ones(size(targets));
            trial = (nextTrialNum:(nextTrialNum+length(targets)-1))';
            nextTrialNum = nextTrialNum+length(targets);

            behavior = cat(1, behavior, cat(2, subjectIndices, runIndices, trial, targets, results, time, ise, endSide));        
        end; clear fileIdx targets results time subjectIndices runIndices trial nextTrialNum

    end; clear c subjid subcode files nextTrialNum;

    save(metaFilename, 'behavior');
else
    load(metaFilename);
end


%% make some plots

perf = zeros(size(SIDS));
mtt  = zeros(size(SIDS));
ise  = zeros(size(SIDS));
side = zeros(size(SIDS));

for c = 1:length(SIDS)
    idx = behavior(:,1)==c;
    perf(c) = mean(behavior(idx,4) == behavior(idx,5));
    mtt(c)  = nanmean(behavior(idx, 6));
    ise(c)  = mean(behavior(idx, 7));
    side(c) = mean(behavior(idx, 8));
end

% if (exist(fullfile(META_DIR, 'chance.mat')))
%     showChance = true;
%     load(fullfile(META_DIR, 'chance.mat'));
% else
%     showChance = false;
% end

%% hitrate plot
figure
bar(perf, 'facecolor', [.5 .5 .5]);
ylabel('Fraction of targets acquired', 'fontsize', FONT_SIZE);
xlabel('subject', 'fontsize', FONT_SIZE);
title('Hit rate by subject', 'fontsize', FONT_SIZE);
set(gca, 'fontsize', LEGEND_FONT_SIZE);
ylim([-0.05 0.5]);

% if (showChance)
%     ax(1) = hline(hit.mu, 'k');
%     ax(2) = hline(hit.lb, 'k:');
%     ax(3) = hline(hit.ub, 'k:');
%     set(ax, 'linewidth', 3);
% end

SaveFig(OUTPUT_DIR, 'behavioral-hitrate', 'eps');
SaveFig(OUTPUT_DIR, 'behavioral-hitrate', 'png');

%% ISE plot
figure
bar(ise, 'facecolor', [.5 .5 .5]);
xlabel('subject', 'fontsize', FONT_SIZE);
ylabel('ISE (screen-seconds)', 'fontsize', FONT_SIZE);
title('Integrated squared error by subject', 'fontsize', FONT_SIZE);
set(gca, 'fontsize', LEGEND_FONT_SIZE);
ylim([-0.2 2]);

% if (showChance)
%     ax(1) = hline(hit.mu, 'k');
%     ax(2) = hline(hit.lb, 'k:');
%     ax(3) = hline(hit.ub, 'k:');
%     set(ax, 'linewidth', 3);
% end

SaveFig(OUTPUT_DIR, 'behavioral-ise', 'eps');
SaveFig(OUTPUT_DIR, 'behavioral-ise', 'png');

%% Endside
figure
bar(side, 'facecolor', [.5 .5 .5]);
xlabel('subject', 'fontsize', FONT_SIZE);
ylabel('Prop. good trials', 'fontsize', FONT_SIZE);
title('Correct workspace side by subject', 'fontsize', FONT_SIZE);
set(gca, 'fontsize', LEGEND_FONT_SIZE);

% if (showChance)
%     ax(1) = hline(hit.mu, 'k');
%     ax(2) = hline(hit.lb, 'k:');
%     ax(3) = hline(hit.ub, 'k:');
%     set(ax, 'linewidth', 3);
% end

SaveFig(OUTPUT_DIR, 'behavioral-ends', 'eps');
SaveFig(OUTPUT_DIR, 'behavioral-ends', 'png');

%% do statistical tests looking for differences in hit rate explainable by the three task parameters

packet(1).cond = behavior(:,4) == behavior(:,5);
packet(1).ofile = 'behavioral-hitratebreakdown';
packet(1).name = 'hit rate';
packet(1).ylims = [-0.05 0.6];

packet(2).cond = behavior(:,7);
packet(2).ofile = 'behavioral-isebreakdown';
packet(2).name = 'ISE (screen-sec)';
packet(2).ylims = [-0.2 2.2];

packet(3).cond = behavior(:,8);
packet(3).ofile = 'behavioral-endingwellbreakdown';
packet(3).name = 'End side';
packet(3).ylims = [-0.05 1];

for p = packet
    isUp = ismember(behavior(:,4), UP);
    isBig = ismember(behavior(:,4), BIG);
    isNear = ismember(behavior(:,4), NEAR);

    dird = zeros(length(SIDS), 2);
    sized = zeros(length(SIDS), 2);
    distd = zeros(length(SIDS), 2);

    for s = 1:length(SIDS)
        idx = behavior(:,1) == s;
        dird(s,:) = [mean(p.cond(idx & ~isUp)) mean(p.cond(idx & isUp))];
        sized(s,:) = [mean(p.cond(idx & ~isBig)) mean(p.cond(idx & isBig))];
        distd(s,:) = [mean(p.cond(idx & ~isNear)) mean(p.cond(idx & isNear))];
    end

    figure
    
    for sub = {{1, dird, 'direction', {'down', 'up'}},{2, distd, 'distance', {'far', 'near'}},{3, sized, 'size', {'small', 'large'}}}
        idx = sub{1}{1};
        data = sub{1}{2};
        label = sub{1}{3};
        legs = sub{1}{4};
    
        [~, ratep] = ttest(data(:,1), data(:,2)); 
        
        if (ratep < 0.05)
            fprintf('there is a significant relationship between %s and %s.  p = %f\n', p.name, label, ratep);
        else
            fprintf('there is NOT a significant relationship between %s and %s.  p = %f\n', p.name, label, ratep);
        end

        subplot(1,3,idx);
        bar(mean(data), 'facecolor', [.5 .5 .5], 'linew', 1); hold on;
        errorbar(mean(data), sem(data), 'color', 'k', 'linew', 1, 'linestyle', 'none');
        title(label, 'fontsize', FONT_SIZE);
        ylabel(p.name, 'fontsize', FONT_SIZE);
        xlim([0 3]); ylim(p.ylims);
        set(gca, 'xticklabel', legs);
        sigstar({legs}, ratep);        
    end
    
    set(gcf,'pos',[624   664   878   314]);
    SaveFig(OUTPUT_DIR, p.ofile, 'eps');
    SaveFig(OUTPUT_DIR, p.ofile, 'png');
end

%%
mrate = [];
means = [];

for s = 1:length(SIDS)
    idx = behavior(:,1) == s;
    f1 = isBig & ~isNear;
    f2 = ~isBig & isNear;
    
    mrate(s,1) = mean(behavior(idx&f1,4)==behavior(idx&f1,5));
    mrate(s,2) = mean(behavior(idx&f2,4)==behavior(idx&f2,5));
end

[h, p] = ttest(mrate(:,1),mrate(:,2));

figure
bar(mean(mrate), 'facecolor', [.5 .5 .5], 'linew', 2); hold on;
errorbar(mean(mrate), sem(mrate), 'color', 'k', 'linew', 2, 'linestyle', 'none');

sigstar({{1, 2}}, p);
set(gca, 'xticklabel', {'speed', 'precision'});
ylabel('hit rate', 'fontsize', FONT_SIZE);
title('performance on Fittsean equivalents', 'fontsize', FONT_SIZE);

SaveFig(OUTPUT_DIR, 'behavioral-fittsean', 'png');
SaveFig(OUTPUT_DIR, 'behavioral-fittsean', 'eps');

%% do statistical tests looking for differences in ise as a function of the task parameters

isHit = behavior(:,4) == behavior(:,5);

isUp = ismember(behavior(isHit,4), UP);
isBig = ismember(behavior(isHit,4), BIG);
isNear = ismember(behavior(isHit,4), NEAR);

ise = behavior(isHit, 7);

% [p, table, stats, terms] = ...
%     anovan(mtt, {isUp, isBig, isNear}, 'varnames', {'isUp', 'isBig', 'isNear'} );

[p, table, stats, terms] = ...
    anovan(ise, {isUp, isBig, isNear}, 'model', 'full', 'varnames', {'isUp', 'isBig', 'isNear'} );

figure;
ax = maineffectsplot(ise, {isUp, isBig, isNear},'varnames', {'Dir', 'Size', 'Dist'});
set(findobj(ax, 'type', 'line'), 'linewidth', 2);
set(findobj(ax, 'type', 'line'), 'marker', 'o');

subplot(131); 
set(gca, 'xticklabel', {'Down', 'Up'});
subplot(132);
set(gca, 'xticklabel', {'Small', 'Big'});
subplot(133);
set(gca, 'xticklabel', {'Far', 'Near'});


SaveFig(OUTPUT_DIR, 'behavioral-main', 'eps');

figure;
h = interactionplot(ise, {isUp, isBig, isNear}, 'varnames', {'isUp', 'isBig', 'isNear'});
set(findobj(h, 'type', 'line'), 'linewidth', 2);
set(findobj(h, 'type', 'line'), 'marker', 'o');

axlist = findobj(h, 'type', 'axes');
set(axlist(3), 'xticklabel', {'small', 'large'});
set(axlist(4), 'xticklabel', {'far', 'near'});
set(axlist(9), 'xticklabel', {'down', 'up'});
set(axlist(10), 'xticklabel', {'small', 'large'});

SaveFig(OUTPUT_DIR, 'behavioral-interaction', 'eps');