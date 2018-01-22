function prettyconfusion(labels, estimates)
%     handle = figure;
    
    %  make a confusion matrix
    [~, ticklabels] = grp2idx([labels; estimates]);
    
    cx = confusionmat(labels, estimates);
    imagesc(cx');
    cm = colormap('gray');
    cm = cm(end:-1:1,:);
    colormap(cm);
    set(gca,'clim',[0,max(max(cx))]);
    
    Nx = size(cx, 1);
    C = length(labels);
    
    for x = 1:Nx
        for y = 1:Nx
            h = text(x, y, sprintf('%d', cx(x,y)));
            if cx(x,y) > 0.5 * max(max(cx))
                set(h, 'color', [1 1 1]);
            else
                set(h, 'color', [0 0 0]);
            end
            set(h, 'fontweight', 'bold');
            set(h, 'horizontalalignment', 'center');
%             set(h, 'fontsize', FONT_SIZE);
        end
    end
    
    axis xy;
    
    set(gca,'xtick',1:Nx);    
    set(gca,'xticklabel',ticklabels);
    xlabel('Truth');
    set(gca,'ytick',1:Nx);
    set(gca,'yticklabel',ticklabels);
    ylabel('Estimate');
%     set(gca,'fontsize',LEGEND_FONT_SIZE);
%     title(sprintf('Classification confusion matrix - %s', sid), 'fontsize', FONT_SIZE);
end