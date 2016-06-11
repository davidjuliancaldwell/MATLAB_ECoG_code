%% stats function for scatter plots

function [p1,p2,p3,p4,p5,cellStats] = scatterplot_stats(d1)

s = inputname(1);

exp =  [d1(:,3);-d1(:,4)];
theory = [d1(:,6);d1(:,6)];
groups = cell(128,1);
groups(1:64) = {'1st'};
groups(65:end) = {'2nd'};

% test if experiment data is normally distributed 
fprintf(['Normality test experiment for ',s]);
[h1,p1,kstat1,crtival1] = lillietest(exp);

% test if theory is normally distributed 
fprintf(['Normality test theory for ',s]);

[h2,p2,kstat2,crtival2] = lillietest(theory);

% signed rank test
fprintf(['Signed rank sum test between experiment and theory for ',s]);
[p3,h3,stats3] = signrank(exp,theory);

% rank sum test
fprintf(['rank sum test between experiment and theory ',s]) ;
[p4,h4,stats4] = ranksum(exp,theory);

% KS test
fprintf(['Kolmogorov Smirnov Test between experiment and theory ',s]);
[h5,p5] = kstest2(exp,theory);

cellStats = [p1 p2 p3 p4 p5];

end