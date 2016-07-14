% distance analysis function

function [channelDistPos,channelDistNeg] = distanceAnalysis(locs,stim1,stim2)

gridSize = 64;
gridMatrix = [1:gridSize];

% calculate distances

distances = matrixDist(locs);

% get distance from a given channel 


% get vectors of the distances from the stimulation channels 
channelDistPos = channelExtract(distances,stim1);
channelDistNeg = channelExtract(distances,stim2);

%% plot the electrode locations as a sanity check

% scatter plot of electrode locations
figure
c = linspace(1,10,size(locs,1));

% take labeling from plot dots direct
h = scatter3(locs(:,1),locs(:,2),locs(:,3),[100],c,'filled');


gridSize = 64;

trodeLabels = [1:gridSize];
for chan = 1:gridSize
    txt = num2str(trodeLabels(chan));
    t = text(locs(chan,1),locs(chan,2),locs(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
    set(t,'clipping','on');
end

%% set logical channels to be goods
% logChans = goods;
% 
% % look at electrode of interest .
% % for 0b5a2e it'll be 14 to start  , also look at 31 and 23
% 
% 
% 
% 
% % using good channels add in goods - 4/6/2016 - DJC
% logChans = gridMatrix;
% logChans(goods) = 0;
% logChans = ~logical(logChans);
% 
% % make matrix of distances from Beta channel
% betaDist_total = [betaDist_total betaDist(logChans)];

end
