%% POSITIVE LAG IMPLIES CONTROL LEADS
Z_Constants;

SID = 1;
CHAN = 2;
TAL = 3:5;
CLASS = 6;
HMAT = 7;
BA = 8;
TYPE = 9;
SIG = 10;
WEIGHT = 11;
TIME = 12;
NUMLAG = 13;
BINLAG = 14;

%%
load(fullfile(META_DIR, 'screened_interactions.mat'), '*result*', 'controlLocs');


% drop the conspicuous subject
badsub = [];
badsub = find(strcmp(SIDS, '38e116'));

resultA(ismember(resultA(:,1), badsub), :) = [];
% resultA(:, LAG) = -resultA(:, LAG);

earlyresultA(ismember(earlyresultA(:,1), badsub), :) = [];
% earlyresultA(:, LAG) = -earlyresultA(:,LAG);

lateresultA(ismember(lateresultA(:,1), badsub), :) = [];
% lateresultA(:, LAG) = -lateresultA(:,LAG);

result(ismember(result(:,1), badsub), :) = [];
% result(:, LAG) = -result(:, LAG);

earlyresult(ismember(earlyresult(:,1), badsub), :) = [];
% earlyresult(:, LAG) = -earlyresult(:, LAG);

lateresult(ismember(lateresult(:,1), badsub), :) = [];
% lateresult(:, LAG) = -lateresult(:, LAG);


%% Here we will make three plots
% interaction count by area
% interaction strength by area
% interaction lag by area

r_sub = resultA;
MAX_P = 0.05;
keeps = (r_sub(:,SIG)   <= 0.05 & r_sub(:, TYPE)==1);

% make all the lefties in to righties
areas = r_sub(keeps, HMAT);
weights = r_sub(keeps, WEIGHT);
lags = r_sub(keeps, NUMLAG);
% lags = sign(r_sub(keeps, BINLAG));

keys = {'Other', 'M1', 'S1', 'PMd', 'PMv'};
values = {[0 5 6 7 8], [1 2], [3 4], [9 10], [11 12]};

counts = zeros(length(keys), 1);
weightMeans = zeros(length(keys), 1);
weightSems  = zeros(length(keys), 1);
lagMeans = zeros(length(keys), 1);
lagSems = zeros(length(keys), 1);

for idx = 1:length(keys)
    goods = ismember(areas, values{idx});
    counts(idx) = sum(goods);    
    weightMeans(idx) = mean(weights(goods));
    weightSems(idx) = sem(weights(goods));
    lagMeans(idx) = mean(lags(goods));
    lagSems(idx) = sem(lags(goods));
end

drops = counts==0;

counts(drops) = [];
weightMeans(drops) = [];
weightSems(drops) = [];
lagMeans(drops) = [];
lagSems(drops) = [];
keys(drops) = [];

[~, sortOrder] = sort(weightMeans, 'descend');

%% finally, make some plots

colors = [.8 .8 .8; 1 0 0; 0 0 1; 0 .498 0; 1 1 0];

% counts
figure;
for i = 1:length(sortOrder)
    bar(i, counts(sortOrder(i)), 'edgecolor', 'k', 'facecolor', colors(sortOrder(i), :));
    set(gca, 'xticklabel', keys(sortOrder(i)));
    hold on;
end

set(gca,'xtick', 1:length(sortOrder))
set(gca, 'xticklabel', keys(sortOrder));
ylabel('Interaction Count', 'fontsize', 18);

title('STWC interactions by area', 'fontsize', 18);
ylim(ylim + [-1 1]);
xlim([0 6]);
set(gcf, 'pos', [624   474   672   304]);
set(gca,'fontsize', 14);
SaveFig(OUTPUT_DIR, 'areas-count', 'eps', '-r600');

% weights
figure;
for i = 1:length(sortOrder)
    bar(i, weightMeans(sortOrder(i)), 'edgecolor', 'k', 'facecolor', colors(sortOrder(i), :));
    set(gca, 'xticklabel', keys(sortOrder(i)));
    hold on;
end

ax = errorbar(weightMeans(sortOrder), weightSems(sortOrder), 'k');
set(ax, 'linestyle', 'none');

set(gca,'xtick', 1:length(sortOrder))
set(gca, 'xticklabel', keys(sortOrder));
% xlabel('Area');
ylabel('STWC Coefficient', 'fontsize', 18);
title('STWC Coefficients by area', 'fontsize', 18);
[h,p] = ttest2(weights(areas==11|areas==12), weights(areas<11))

ylim([min(weightMeans-weightSems)-.1*(abs(min(weightMeans-weightSems))) max(weightMeans+weightSems)+.1*max(weightMeans+weightSems)])
xlim([0 6]);
sigstar({{1,3.5}}, p);
set(gcf, 'pos', [624   474   672   304]);
set(gca, 'fontsize', 14);
SaveFig(OUTPUT_DIR, 'areas-weight', 'eps', '-r600');


% lags
figure;
for i = 1:length(sortOrder)
    bar(i, lagMeans(sortOrder(i)), 'edgecolor', 'k', 'facecolor', colors(sortOrder(i), :));
    set(gca, 'xticklabel', keys(sortOrder(i)));
    hold on;
end

ax = errorbar(lagMeans(sortOrder), lagSems(sortOrder), 'k');
set(ax, 'linestyle', 'none');

set(gca,'xtick', 1:length(sortOrder))
set(gca, 'xticklabel', keys(sortOrder));
% xlabel('Area');
ylabel('Interaction lag (sec)', 'fontsize', 18);
title('Interaction lags by area', 'fontsize', 18);

[h,p] = ttest2(lags(areas==11|areas==12), lags(areas<11))
sigstar({{1,3.5}}, p);

ylim([-.1 .1])
xlim([0 6]);
set(gca,'ytick',[-.1 .1])
set(gcf, 'pos', [624   474   672   304])
set(gca, 'fontsize', 14);
SaveFig(OUTPUT_DIR, 'areas-lag', 'eps', '-r600');

%% simple statistical comparison
