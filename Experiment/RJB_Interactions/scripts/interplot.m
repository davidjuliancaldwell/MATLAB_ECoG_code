function interplot(interaction, t, lag)
    figure
    
    load('interaction_colormap');
    
    for c = 1:size(interaction, 1)
        subplot(size(interaction, 1), 1, c);
        imagesc(t, lag, squeeze(interaction(c, :, :)));
        colorbar;
        colormap(cm);
    end
end