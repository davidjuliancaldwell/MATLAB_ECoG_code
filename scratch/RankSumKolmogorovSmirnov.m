%% DJC - 2-10-2016
% This is a script to try and compare the two sample kolmogorov-smirnov
% test to the Mann Whitney rank sum test in MATLAB using examples from the
% MATLAB website 

% from Kolmogorov-Smironov example

x1 = wblrnd(1,1,1,50);
x2 = wblrnd(1.2,2,1,50);

figure
subplot(2,1,1)
plot(x1)
title('x1')
subplot(2,1,2)
plot(x2)
title('x2')



[pR,hR,statsR] = ranksum(x1,x2)

[hK,pK,k2stat] = kstest2(x1,x2)

% from rank sum example

rng('default') % for reproducibility
x = unifrnd(0,1,10,1);
y = unifrnd(0.25,1.25,15,1);


figure
subplot(2,1,1)
plot(x)
title('x')
subplot(2,1,2)
plot(y)
title('y')


[pR,hR,statsR] = ranksum(x,y)

[hK,pK,k2stat] = kstest2(x,y)