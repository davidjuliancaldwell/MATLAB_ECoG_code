function handle = PlotBrodmann(areas, weights)
    % load in the talairach brain
    load(fullfile(myGetenv('subject_dir'), 'tail', 'surf', 'tail_cortex_rh_lowres.mat'))
    
    % get the corresponding brodmann areas
    areafile = fullfile(myGetenv('subject_dir'), 'tail', 'surf', 'tail_bas.mat');
    
    if (~exist(areafile, 'file'))
        vertexAreas = brodmannAreaForElectrodes(lowres_cortex.vertices, true);
        temp = brodmannAreaForElectrodes(lowres_cortex.vertices(5001:end,:), true);
        vertexAreas(5001:end) = temp;
        
        save(areafile, 'vertexAreas');
    else
        load(areafile, 'vertexAreas');
    end
    
    cortex = lowres_cortex;
    
    % figure out the appropriate weights    
    cs = zeros(size(vertexAreas))';
    
    uAreas = unique(areas);
    for uAreaIdx = 1:length(uAreas)
        idxs = vertexAreas==uAreas(uAreaIdx);
        cs(idxs) = weights(uAreaIdx);        
    end
        
    % draw the cortex 
%     figure
    
    handle = patch('faces',[cortex.faces],...
        'vertices',[cortex.vertices],...
        'facevertexcdata',cs,...
        'facecolor',get(gca,'DefaultSurfaceFaceColor'), ...
        'edgecolor','none',...
        'parent',gca);
    
    axis equal;
    set(gcf,'Renderer','OpenGL') % Tim's edit! For teh speedzor!
    axis tight;
    shading interp;
    lighting gouraud; %play with lighting...
    material([.3 .8 .1 10 1]);
end