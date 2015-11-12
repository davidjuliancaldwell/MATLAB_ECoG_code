%% 11-11-2015 - writing a function to plot a line graph as a heatmap with Luke

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

function [N,C] = LinePlotHeatMapFunction(t, ChannelSignal)

% replicate the time vector into a single long time vector by however many
% trials you want to look at

tVec = repmat(t,1,size(ChannelSignal,2))';

% initialize an empty vector that will be all of trials lined up one after
% one another

sigMatVec = [];

% this takes the nxm matrix of n samples x m observations, and stacks them
% end on end to create one long vector that is the product of their two
% lengths
for i = 1:size(ChannelSignal,2)
    sigMatVec = [sigMatVec; ChannelSignal(:,i)];
end

% this sets the bin size (how fine of a resolution) for hist3. make bins
% larger to get finer resolution, smaller values for coarser resolution
bins = [1000 1000];

%imagesc heatmap in 2D
figure
[N,C] = hist3([tVec sigMatVec],bins);
imagesc(C{1},C{2},N');
set(gca,'YDir','normal')
xlabel('Time (seconds)'); ylabel('Amplitude (\muV)');
colorbar

%3d histogram
figure
hist3([tVec sigMatVec],bins,'FaceAlpha',.65);
xlabel('Time (seconds)'); ylabel('Amplitude (\muV)');
set(gcf,'renderer','opengl');
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
colorbar
end


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


