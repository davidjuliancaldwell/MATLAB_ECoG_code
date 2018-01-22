function [highPolyPatchHandle lowPolyPatchHandle] = PlotCortex(subject, hemisphere,LowResHack, alpha)

    debugColors = 0;

    if ~exist('alpha', 'var')
        alpha = 1;
    end
    
    if ~exist('hemisphere','var')
        hemisphere = 'both';
    end

    subjDir = getSubjDir(subject);

    switch hemisphere
        case 'lh'
        case 'rh'
        case 'both'
        case 'l'
            hemisphere = 'lh';
        case 'r'
            hemisphere = 'rh';
        case 'b'
            hemisphere = 'both';
        otherwise
            error('Bad hemisphere. Need l/lh, r/rh, or b/both.');
    end
    
    %% LOW RES HACK ONLy
    if exist('LowResHack','var') && ~isempty(LowResHack)
        if strcmp(LowResHack,'yesimsureiwanttousethelowreshack') == 0
            error('Don''t use LowResHack!! just ignore it!!');
        end
        [highPolyPatchHandle lowPolyPatchHandle] = DoLowRes(subject, subjDir, hemisphere);
        return;
    end
    %% LOW RES HACK ONLY

    highPolyModel = fullfile(subjDir, 'surf', [subject '_cortex_' hemisphere '_hires.mat']);    
    lowPolyModel = fullfile(subjDir, 'surf', [subject '_cortex_' hemisphere '_lowres.mat']);

    if (~exist(highPolyModel, 'file'))
        highPolyModel = fullfile(subjDir, 'surf', sprintf('%s_cortex', subject));
    end
    
    lpmSwitch = false;
    if (~exist(lowPolyModel, 'file'))
        lowPolyModel = fullfile(subjDir, 'surf', sprintf('%s_cortex', subject));
        lpmSwitch = true;
    end
    
    
    load(lowPolyModel);    
    if (lpmSwitch)
        % needed for old cortices
        lowres_cortex = correctCortexForOldVersions(cortex);
    else
        lowres_cortex = correctCortexForOldVersions(lowres_cortex);
    end
    
    load(highPolyModel);   
    cortex = correctCortexForOldVersions(cortex);
 
    if debugColors == 1
        hiResHandle = PlotBrain(cortex,[1 .4 .4]);
        hold on;
        lowResHandle = PlotBrain(lowres_cortex,[0 1 0]);
    else
        hiResHandle = PlotBrain(cortex, [], alpha);
        hold on;
        lowResHandle = PlotBrain(lowres_cortex, [], alpha);
    end
    
    if nargout == 1
        highPolyPatchHandle = hiResHandle;
    elseif nargout == 2
        highPolyPatchHandle = hiResHandle;
        lowPolyPatchHandle = lowResHandle;
    end
    

        lightScale = .8;

    view(90,90);
    l = camlight('headlight');
    set(l,'color',[lightScale lightScale lightScale]*.5);
    view(90,-90);
    l = camlight('headlight');
    set(l,'color',[lightScale lightScale lightScale]*.5);
    view(90,0);
    l = camlight('headlight');
    set(l,'color',[lightScale lightScale lightScale]);
    view(-90,0);
    l = camlight('headlight');
    set(l,'color',[lightScale lightScale lightScale]);
    
%     l = light;
    
    if strcmp(hemisphere,'lh')==1
        view(270, 0);
%         set(l,'Position',[-1 0 1])        
    elseif strcmp(hemisphere,'rh')==1
        view(90, 0);
%         set(l,'position',[1 0 1]);
    else
        view(90, 45);
    end
    
    set(lowResHandle,'visible','off');
    
    panHandle = pan(gcf);
    rotateHandle = rotate3d(gcf);
    zoomHandle = zoom(gcf);
    
    set(rotateHandle,'ActionPreCallback',@rotationStarted);
    set(rotateHandle,'ActionPostCallback',@rotationDone);
    
    set(zoomHandle,'ActionPreCallback',@zoomStarted)
    set(zoomHandle,'ActionPostCallback',@zoomEnded)
    
    set(panHandle,'ActionPreCallback',@panStarted)
    set(panHandle,'ActionPostCallback',@panEnded)
    
    set(gcf,'userdata',{hiResHandle, lowResHandle});
    
    axis off;
  

end

function [highPolyPatchHandle lowPolyPatchHandle] = DoLowRes(subject, subjDir, hemisphere)
    load([subjDir '/surf/' subject '_cortex.mat']);
    highPolyPatchHandle = PlotBrain(cortex);
    lowPolyPatchHandle = PlotBrain(cortex);
    
    l=light;
    
    if strcmp(hemisphere,'lh')==1
        view(270, 0);
        set(l,'Position',[-1 0 1])        
    elseif strcmp(hemisphere,'rh')==1
        view(90, 0);
        set(l,'position',[1 0 1]);
    else
        view(90, 45);
    end
    
    set(lowPolyPatchHandle,'visible','off');
    
    panHandle = pan(gcf);
    rotateHandle = rotate3d(gcf);
    zoomHandle = zoom(gcf);
    
    set(rotateHandle,'ActionPreCallback',@rotationStarted);
    set(rotateHandle,'ActionPostCallback',@rotationDone);
    
    set(zoomHandle,'ActionPreCallback',@zoomStarted)
    set(zoomHandle,'ActionPostCallback',@zoomEnded)
    
    set(panHandle,'ActionPreCallback',@panStarted)
    set(panHandle,'ActionPostCallback',@panEnded)
    
    set(gcf,'userdata',{highPolyPatchHandle, lowPolyPatchHandle});
    
    axis off;
end

function handle = PlotBrain(cortex, color, alpha)
    if (~exist('color','var') || isempty(color))
        color = [0.7 .7 .7];
    end
    if ~exist('alpha', 'var')
        alpha = 1;
    end
    
    handle = patch('faces',[cortex.faces],...
        'vertices',[cortex.vertices],...
        'facevertexcdata',repmat(color, size(cortex.vertices,1),1),...
        'facecolor',get(gca,'DefaultSurfaceFaceColor'), ...
        'edgecolor','none',...
...%         'parent',gca);
        'parent',gca, 'FaceAlpha', alpha);
    axis equal;
    set(gcf,'Renderer','OpenGL') % Tim's edit! For teh speedzor!
    axis tight;
    shading interp;
    lighting gouraud; %play with lighting...
    material([.3 .8 .1 10 1]);

end

function b = correctCortexForOldVersions(a)
    mfields = fields(a);
    for field = mfields'
        field = field{:};
        
        if (strcmp(field, 'vert') == 1)
            b.vertices = a.vert;
        elseif (strcmp(field, 'tri') == 1)
            b.faces = a.tri;
        else
            cmd = sprintf('b.%s = a.%s;', field, field) ;
            eval(cmd);
        end        
    end
end

function rotationStarted(a, b)
    out = get(a.figure,'userdata');
    [high low] = out{1:2};
    ShowLowPolyCortex(high, low);
end

function rotationDone(a, b)
    out = get(a.figure,'userdata');
    [high low] = out{1:2};
    ShowHighPolyCortex(high, low);
end

function zoomStarted(a,b)
    out = get(a.figure,'userdata');
    [high low] = out{1:2};
    ShowLowPolyCortex(high, low);
end

function zoomEnded(a,b)
    out = get(a.figure,'userdata');
    [high low] = out{1:2};
    ShowHighPolyCortex(high, low);
end

function panStarted(a,b)
    out = get(a.figure,'userdata');
    [high low] = out{1:2};
    ShowLowPolyCortex(high, low);
end

function panEnded(a,b)
    out = get(a.figure,'userdata');
    [high low] = out{1:2};
    ShowHighPolyCortex(high, low);
end