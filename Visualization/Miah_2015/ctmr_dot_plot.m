function ctmr_dot_plot(cortex, electrodes, weights, viewSide, clims, markerSize, colorMapName)
if (isempty(clims))
    clims = [-1 1];
end

if (isempty(markerSize))
    markerSize = 15;
end
v = viewSide;

if ~isfield(cortex, 'vert')
    cortex.vert = cortex.vertices;
end

if ~isfield(cortex, 'tri');
    cortex.tri = cortex.faces;
end


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


l = length(cortex.vert);
c = zeros(l,1);
tripatch(cortex, 0, c);
% patch(cortex,'edgecolor','none','facecolor','interp');

if (~exist('colorMapName','var') || isempty(colorMapName))
    load('loc_colormap');
else
    cm = colormap(colorMapName);
end

    axis tight;
    axis equal;

% cortex.facevertexcdata = c';

shading interp;
l=light;
colormap(cm);

lighting gouraud;
material([.3 .8 .1 10 1]);
% material dull;
axis off
set(gcf,'renderer','zbuffer')
hold on
% plot3(electrodes(:,1),electrodes(:,2),electrodes(:,3),'rh')

minWeight = clims(1);
maxWeight = clims(2);

minColor = cm(1,:);
maxColor = cm(end,:);

alphas = (weights - minWeight) / (maxWeight - minWeight);
idxs = alphas*length(cm);

for chan=1:size(electrodes,1)
    if (isnan(weights(chan)))
        plot3(electrodes(chan,1), electrodes(chan,2), electrodes(chan,3),'.','Color',[0 0 0], 'MarkerSize', round(markerSize/2));
    else
        idx = idxs(chan);

        startColor = cm(floor(idx),:);
        endColor   = cm(ceil(idx),:);

        off = idx-floor(idx);
        trueColor = (1 - off) * startColor + off * endColor;

    %     trueColor = (1 - alpha) * minColor + alpha * maxColor;
        plot3(electrodes(chan,1),electrodes(chan,2),electrodes(chan,3),'o','MarkerFaceColor',trueColor,'MarkerSize',markerSize,'MarkerEdgeColor','k')%i like red (white would be [1 1 1], etc) dots better
        txt = num2str(chan);
        t = text(electrodes(chan,1),electrodes(chan,2),electrodes(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
        set(t,'clipping','on');
    end
end
% plot3(electrodes(:,1),electrodes(:,2),electrodes(:,3),'o','Color',[0 0 0],'MarkerSize',markerSize * 0.33)%i like red (white would be [1 1 1], etc) dots better
% set(gcf,'Color',[1 1 1])

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




% function PlotWeightedElectrodes(cortex, electrodes, weights, viewSide, clims, markerSize, colorMapName)
% if (isempty(clims))
%     clims = [-1 1];
% end
% 
% if (isempty(markerSize))
%     markerSize = 40;
% end
% v = viewSide;
% 
% 
% % rel_dir=which('loc_plot');
% % rel_dir((length(rel_dir)-10):length(rel_dir))=[];
% 
% % if t=='w'
% %     template='wholebrain.mat';load(strcat(rel_dir,'\template\',template));
% %     temp=0;
% % elseif t=='r'
% %     template='halfbrains.mat';load(strcat(rel_dir,'\template\',template));
% %     cortex=rightbrain;
% %     temp=0;
% % elseif t=='l'
% %     template='halfbrains.mat';load(strcat(rel_dir,'\template\',template));
% %     cortex=leftbrain;
% %     temp=0;
% % end
% 
% if ~isfield(cortex, 'vert')
%     cortex.vert = cortex.vertices;
% end
% 
% if ~isfield(cortex, 'tri');
%     cortex.tri = cortex.faces;
% end
% 
% l = length(cortex.vert);
% c = zeros(l,1);
% tripatch(cortex, 0, c);
% % patch(cortex,'edgecolor','none','facecolor','interp');
% 
% if (~exist('colorMapName','var') || isempty(colorMapName))
%     load('loc_colormap');
% else
%     cm = colormap(colorMapName);
% end
% 
%     axis tight;
%     axis equal;
% 
% % cortex.facevertexcdata = c';
% 
% shading interp;
% l=light;
% colormap(cm);
% 
% lighting gouraud;
% material([.3 .8 .1 10 1]);
% % material dull;
% axis off
% set(gcf,'renderer','zbuffer')
% hold on
% % plot3(electrodes(:,1),electrodes(:,2),electrodes(:,3),'rh')
% 
% minWeight = clims(1);
% maxWeight = clims(2);
% 
% minColor = cm(1,:);
% maxColor = cm(end,:);
% 
% alphas = (weights - minWeight) / (maxWeight - minWeight);
% idxs = alphas*length(cm);
% 
% for chan=1:size(electrodes,1)
%     if (isnan(weights(chan)))
%         plot3(electrodes(chan,1), electrodes(chan,2), electrodes(chan,3),'.','Color',[0 0 0], 'MarkerSize', round(markerSize/2));
%     else
%         idx = idxs(chan);
% 
%         startColor = cm(floor(idx),:);
%         endColor   = cm(ceil(idx),:);
% 
%         off = idx-floor(idx);
%         trueColor = (1 - off) * startColor + off * endColor;
% 
%     %     trueColor = (1 - alpha) * minColor + alpha * maxColor;
%         plot3(electrodes(chan,1),electrodes(chan,2),electrodes(chan,3),'.','Color',trueColor,'MarkerSize',markerSize)%i like red (white would be [1 1 1], etc) dots better
%     end
% end
% % plot3(electrodes(:,1),electrodes(:,2),electrodes(:,3),'o','Color',[0 0 0],'MarkerSize',markerSize * 0.33)%i like red (white would be [1 1 1], etc) dots better
% % set(gcf,'Color',[1 1 1])
% 
% if v=='l'
%     view(270, 0);
%     set(l,'Position',[-1 0 1])        
% elseif v=='r'
%     view(90, 0);
%     set(l,'Position',[1 0 1])        
% end
% % disp('---------------------------------------------------')
% % disp('plotted electrode locations in talairach')
% % display([[1:length(electrodes(:,1))]' electrodes]);
% % disp('---------------------------------------------------')
% %exportfig
% % if plot_opt=='yes'
% %     exportfig(gcf, strcat(cd,'\figout.png'), 'format', 'png', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 600, 'Width', 4, 'Height', 3);
% %     disp('figure saved as "figout"');
% % end