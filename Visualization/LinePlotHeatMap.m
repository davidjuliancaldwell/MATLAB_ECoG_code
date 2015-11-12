%% 11-6-2015 - writing a script to plot a line graph as a heatmap with Luke

% The idea is as follows, Consider the following: I'll build a test signals
% (out of sine waves of different amplitude), then I'll plot the heatmap
% via hist3 and imagesc.

% The idea is to build an auxiliary signal which is just the juxtaposition
% of all your time histories (both in x and y), then extract basic
% bivariate statistics out of that.
%  % # Test signals xx = 0 : .01 : 2* pi; center = 1; eps_ = .2; amps =
%  linspace(center - eps_ , center + eps_ , 100 );
% 
%  % # the auxiliary signal will be stored in the following variables yy =
%  []; xx_f = [];
% 
%  for A = amps
%    xx_f = [xx_f,xx]; yy = [yy A*sin(xx)];
%  end
% 
%  % # final heat map colormap(hot) [N,C] = hist3([xx_f' yy'],[100 100]);
%  imagesc(C{1},C{2},N')

load('ecb43e_LarryStatsRAW.mat');
sigInterest = kwinsTotal;
sigMat = zeros(length(kwinsTotal),size(kwinsTotal{1},1),size(kwinsTotal{1},2));
for i = 1:size(sigInterest)
    sigMat(1,:,:) = sigInterest{i};
end

tVec = repmat(t,1,size(sigMat,3))';

channelInt = input('Whats your channel of interest? ');
sigMatInt = [];
sigMatInt = squeeze(sigMat(channelInt,:,:));
sigMatVec = [];

for i = 1:size(sigMatInt,2)
    sigMatVec = [sigMatVec; sigMatInt(:,i)];
end

figure
[N,C] = hist3([tVec sigMatVec],[1000 1000]);
imagesc(C{1},C{2},N');
set(gca,'YDir','normal')




%% Inspiration from http://www.hitmaroc.net/287989-6584-plotting-many-lines-heatmap.html

% The idea is as follows, Consider the following: I'll build a test signals
% (out of sine waves of different amplitude), then I'll plot the heatmap
% via hist3 and imagesc.

% The idea is to build an auxiliary signal which is just the juxtaposition
% of all your time histories (both in x and y), then extract basic
% bivariate statistics out of that.
%  % # Test signals xx = 0 : .01 : 2* pi; center = 1; eps_ = .2; amps =
%  linspace(center - eps_ , center + eps_ , 100 );
% 
%  % # the auxiliary signal will be stored in the following variables yy =
%  []; xx_f = [];
% 
%  for A = amps
%    xx_f = [xx_f,xx]; yy = [yy A*sin(xx)];
%  end
% 
%  % # final heat map colormap(hot) [N,C] = hist3([xx_f' yy'],[100 100]);
%  imagesc(C{1},C{2},N')


