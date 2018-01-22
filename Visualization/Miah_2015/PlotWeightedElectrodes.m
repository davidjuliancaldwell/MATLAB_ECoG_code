function PlotWeightedElectrodes(cortex, electrodes, weights, viewSide, baseColor, scaleColor, markerSize, artificialMax)
if (isempty(markerSize))
    markerSize = 40;
end
v = viewSide;


% rel_dir=which('loc_plot');
% rel_dir((length(rel_dir)-10):length(rel_dir))=[];

% if t=='w'
%     template='wholebrain.mat';load(strcat(rel_dir,'\template\',template));
%     temp=0;
% elseif t=='r'
%     template='halfbrains.mat';load(strcat(rel_dir,'\template\',template));
%     cortex=rightbrain;
%     temp=0;
% elseif t=='l'
%     template='halfbrains.mat';load(strcat(rel_dir,'\template\',template));
%     cortex=leftbrain;
%     temp=0;
% end


% tripatch(cortex, '');
patch(cortex,'edgecolor','none','facecolor','interp');

load('loc_colormap');
colormap(cm);

    axis tight;
    axis equal;

% cortex.facevertexcdata = c';

set(gcf,'renderer','zbuffer')
shading interp;
lighting gouraud;
material dull;
l=light;
axis off
hold on
% plot3(electrodes(:,1),electrodes(:,2),electrodes(:,3),'rh')

minWeights = max(0,min(weights));

for chan=1:size(electrodes,1)
    if exist('artificialMax','var')
        alpha = max(0,(weights(chan) - minWeights) / (artificialMax - minWeights));
    else
        alpha = max(0,(weights(chan) - minWeights) / (max(weights) - minWeights));
    end
    
    
    trueColor = (1 - alpha) * baseColor + alpha * scaleColor;
    plot3(electrodes(chan,1),electrodes(chan,2),electrodes(chan,3),'.','Color',trueColor,'MarkerSize',markerSize)%i like red (white would be [1 1 1], etc) dots better
end
plot3(electrodes(:,1),electrodes(:,2),electrodes(:,3),'o','Color',[0 0 0],'MarkerSize',markerSize * 0.33)%i like red (white would be [1 1 1], etc) dots better
set(gcf,'Color',[1 1 1])

if v=='l'
    view(270, 0);
    set(l,'Position',[-1 0 1])        
elseif v=='r'
    view(90, 0);
    set(l,'Position',[1 0 1])        
end
% disp('---------------------------------------------------')
% disp('plotted electrode locations in talairach')
% display([[1:length(electrodes(:,1))]' electrodes]);
% disp('---------------------------------------------------')
%exportfig
% if plot_opt=='yes'
%     exportfig(gcf, strcat(cd,'\figout.png'), 'format', 'png', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 600, 'Width', 4, 'Height', 3);
%     disp('figure saved as "figout"');
% end