% load montage
sid = input('what is the subject ID ? \n','s');
SUB_DIR = fullfile(myGetenv('subject_dir'));
montageFilepath = strcat(SUB_DIR,'\',sid,'\',sid,'_Montage.mat');
load(montageFilepath);

%%

% get electrode locations
locs = trodeLocsFromMontage(sid, Montage, false);
%Grid = locs;

%%
% scatter plot of electrode locations
figure
c = linspace(1,10,size(locs,1));

% take labeling from plot dots direct
h = scatter3(locs(:,1),locs(:,2),locs(:,3),[100],c,'filled');


%%
% scatter plot of electrode locations - colored by number in order 
figure
hold on
numStrips = length(Montage.Montage);
colors = distinguishable_colors(numStrips);

% take labeling from plot dots direct
for i = 1:numStrips
 scatter3(locs(:,1),locs(:,2),locs(:,3),[100],colors(i,:),'filled');
end
%%
gridSize = 8;

trodeLabels = [1:gridSize];
for chan = 1:gridSize
    txt = num2str(trodeLabels(chan));
    t = text(locs(chan,1),locs(chan,2),locs(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
    set(t,'clipping','on');
end
%%
% plot cortex too
figure
PlotCortex(sid,'b')
hold on
h = scatter3(locs(:,1),locs(:,2),locs(:,3),100,c,'filled')
for chan = 1:gridSize
    txt = num2str(trodeLabels(chan));
    t = text(locs(chan,1),locs(chan,2),locs(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
    set(t,'clipping','on');
end

%%
sid = '7dbdec';
figure
PlotCortex(sid,'b',[],0.5)
hold on
PlotElectrodes(sid)

