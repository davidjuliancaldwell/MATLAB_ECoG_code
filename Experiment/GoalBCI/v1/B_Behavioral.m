%% define constants
tcs;

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

FONT_SIZE = 20;
LEGEND_FONT_SIZE = 14;

SIDS = {'d6c834', '6cc87c', 'ada1ab', '6b68ef'};
SUBCODES = {'S1','S2','S3','S4'};

UP = [1 2 3 4];
DOWN = [5 6 7 8];
FAR = [1 2 7 8];
NEAR = [3 4 5 6];
BIG = [2 4 6 8];
SMALL = [1 3 5 7];

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
    
    behavior = [];

    for c = 2:length(SIDS);
        subjid = SIDS{c};
        subcode = SUBCODES{c};

        fprintf ('processing %s: \n', subcode);

        files = goalDataFiles(subjid);

        nextTrialNum = 1;

        for fileIdx = 1:length(files)
            fprintf('  file %d of %d\n', fileIdx, length(files));
return
            [targets, results, time, ise] = extractGoalBCIPerformance(files{fileIdx});

            subjectIndices = c * ones(size(targets));
            runIndices = fileIdx * ones(size(targets));
            trial = (nextTrialNum:(nextTrialNum+length(targets)-1))';
            nextTrialNum = nextTrialNum+length(targets);

            behavior = cat(1, behavior, cat(2, subjectIndices, runIndices, trial, targets, results, time, ise));        
        end; clear fileIdx targets results time subjectIndices runIndices trial nextTrialNum

    end; clear c subjid subcode files nextTrialNum;

    save(metaFilename, 'behavior');
else
    load(metaFilename);
end


%% make some plots

cs = unique(behavior(:, 1));

perf = {};
mtt = {};
ise = {};

for c = cs'
    behaviorSub = behavior(behavior(:, 1)==c, :);

    rs = unique(behaviorSub(:, 2));
    
    for r = rs'
        behaviorRun = behaviorSub(behaviorSub(:, 2)==r, :);
        
        % assuming cs and rs start with 1 and are continuous
        hits = behaviorRun(:,4) == behaviorRun(:,5);
        perf{c}(r) = mean(hits);
        mtt{c}(r) = mean(behaviorRun(hits, 6));     
        ise{c}(r) = mean(behaviorRun(:,7));
    end
end

if (exist(fullfile(META_DIR, 'chance.mat')))
    showChance = true;
    load(fullfile(META_DIR, 'chance.mat'));
else
    showChance = false;
end

% hit rate by run
figure
for c = cs'
    ax = plot(perf{c}-.003, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'Color', theme_colors(2, :));
    legendOff(ax);
    hold on;
    plot(perf{c}, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'Color', theme_colors(c+4, :));    
end
xlabel('run', 'fontsize', FONT_SIZE);
ylabel('Fraction of targets acquired', 'fontsize', FONT_SIZE);
title('Hit rate by run', 'fontsize', FONT_SIZE);
legend(SUBCODES);
set(gca, 'fontsize', LEGEND_FONT_SIZE);

if (showChance)
    ax(1) = hline(hit.mu, 'k');
    ax(2) = hline(hit.lb, 'k:');
    ax(3) = hline(hit.ub, 'k:');
    set(ax, 'linewidth', 3);
end


SaveFig(OUTPUT_DIR, 'behavioral-hitrate', 'eps');

% target acquisition time by run
figure
for c = cs'
    ax = plot(mtt{c}-.015, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'Color', theme_colors(2, :));
    legendOff(ax);
    hold on;
    plot(mtt{c}, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'Color', theme_colors(c+4, :));    
end
xlabel('run', 'fontsize', FONT_SIZE);
ylabel('mean time to acquisition (s)', 'fontsize', FONT_SIZE);
title('Acquisition time by run', 'fontsize', FONT_SIZE);
legend(SUBCODES);
set(gca, 'fontsize', LEGEND_FONT_SIZE);

SaveFig(OUTPUT_DIR, 'behavioral-mtt', 'eps');

% ISE by run
figure
for c = cs'
    ax = plot(ise{c}-.007, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'Color', theme_colors(2, :));
    legendOff(ax);
    hold on;
    plot(ise{c}, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'Color', theme_colors(c+4, :));    
end
xlabel('run', 'fontsize', FONT_SIZE);
ylabel('ISE (screen-seconds)', 'fontsize', FONT_SIZE);
title('Integrated squared error by run', 'fontsize', FONT_SIZE);
legend(SUBCODES);
set(gca, 'fontsize', LEGEND_FONT_SIZE);

if (showChance)
    ax(1) = hline(err.mu, 'k');
    ax(2) = hline(err.lb, 'k:');
    ax(3) = hline(err.ub, 'k:');
    set(ax, 'linewidth', 3);    
end

SaveFig(OUTPUT_DIR, 'behavioral-ise', 'eps');

%% do statistical tests looking for differences in hit rate explainable by the three task parameters

isUp = ismember(behavior(:,4), UP);
isBig = ismember(behavior(:,4), BIG);
isNear = ismember(behavior(:,4), NEAR);

isHit = behavior(:,4) == behavior(:,5);

dirTable = [sum( isUp & ~isHit) sum( isUp & isHit);
            sum(~isUp & ~isHit) sum(~isUp & isHit)];
        
distTable = [sum( isNear & ~isHit) sum( isNear & isHit);
             sum(~isNear & ~isHit) sum(~isNear & isHit)];
        
sizeTable = [sum( isBig & ~isHit) sum( isBig & isHit);
             sum(~isBig & ~isHit) sum(~isBig & isHit)];
        

ratep(1) = chi2pdf(chiTable(dirTable), 1);
ratep(2) = chi2pdf(chiTable(distTable), 1);
ratep(3) = chi2pdf(chiTable(sizeTable), 1);

modulatorLabel = {'direction', 'distance', 'size'};

for c = 1:3
    if (ratep(c) < 0.05)
        fprintf('there is a significant interaction between hit rate and %s.  p = %f\n', modulatorLabel{c}, ratep(c));
    else
        fprintf('there is NOT a significant interaction between hit rate and %s.  p = %f\n', modulatorLabel{c}, ratep(c));
    end
end

figure

subplot(131);
bar([mean(isHit(~isUp)), mean(isHit(isUp))]);
title('direction', 'fontsize', FONT_SIZE);
ylabel('hit rate', 'fontsize', FONT_SIZE);
xlim([0 3]); ylim([-0.05 0.5]);
set(gca, 'xticklabel', {'down', 'up'});
sigstar({{'down', 'up'}}, ratep(1));

subplot(132);
bar([mean(isHit(~isNear)), mean(isHit(isNear))]);
title('distance', 'fontsize', FONT_SIZE);
ylabel('hit rate', 'fontsize', FONT_SIZE);
xlim([0 3]); ylim([-0.05 0.5]);
set(gca, 'xticklabel', {'far', 'near'});
sigstar({{'far', 'near'}}, ratep(2));

subplot(133);
bar([mean(isHit(~isBig)), mean(isHit(isBig))]);
title('size', 'fontsize', FONT_SIZE);
ylabel('hit rate', 'fontsize', FONT_SIZE);
xlim([0 3]); ylim([-0.05 0.5]);
set(gca, 'xticklabel', {'small', 'large'});
sigstar({{'small', 'large'}}, ratep(3));

SaveFig(OUTPUT_DIR, 'behavioral-hitratebreakdown', 'eps');
% plot2svg(fullfile(OUTPUT_DIR, 'behavioral-hitratebreakdown.svg'), gcf);
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

% SaveFig(OUTPUT_DIR, 'behavioral-mttanova', 'png');
% plot2svg(fullfile(OUTPUT_DIR, 'behavioral-mttanova.svg'), gcf);





