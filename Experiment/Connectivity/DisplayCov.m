function DisplayCov

    chan = 17;
    StimCode = 4;
    % Basic function illustrating the ability to update all the axes on
    % rotation. It's kinda hacky/kludgy, but it works.
    % Usage: Rotate the plot once to have the subaxes show up.
    
    % NOTE: Z-order of electrodes is currently IGNORED!! Todo: have the
    % return values of GetScreenCoordsForPoint be returned sorted
    % back-to-front by Z-order
    
%     load('D:\Research\output\WindowLagCov\tripatch_cortex.mat');
%     load('D:\Research\output\WindowLagCov\trodes.mat');
    origFig = figure;
    origAxis = axes;
    [highHandle lowHandle] = PlotCortex('deca10','rh');
    load([getSubjDir('deca10') 'trodes.mat']);
    load(sprintf('D:\\Research\\output\\fingerflex\\srcChan %03i\\sc_%i.mat',chan, StimCode));
    
    % temp
%     Grid = [asma; psma];
    
%     load('colordmap.mat');
    
    fprintf('ROTATE ME!\n');
    
%     origFig = figure;
%     origAxis = axes;
%     ctmr_gauss_plot(cortex, [0 0 0],0,'r');
    
    
    
    for i=1:64;
        gridAxis(i) = axes;

        % set data for axes here?        
        trode = i;
        if(i==chan)
            set(gridAxis(i),'color',[0 1 0]);
%             axis off;
            set(gridAxis(i),'visible','off');
            
            continue;
        end
        if i > chan
            h(i) = imagesc(allPlots(:,:,i-1));
        else
            h(i) = imagesc(allPlots(:,:,i));
        end
        
        maxClim = .6;
        set_colormap_threshold(gridAxis(i), [-maxClim maxClim]*.2, [-maxClim maxClim], [1 1 1]);
        axis off;
        set(gridAxis(i),'visible','off');
        set(get(gridAxis(i),'children'),'visible','off');
    end
    
    uData = {Grid, origAxis, gridAxis, highHandle, lowHandle};
   
    set(gcf,'currentaxes',origAxis);
    hRot = rotate3d(origAxis);
    hZoom = zoom(origAxis);
    
    set(hRot,'ActionPreCallback',@rotationStarted);
    set(hRot,'ActionPostCallback',@rotationDone);
    
    set(hZoom,'ActionPreCallback',@zoomStarted);
    set(hZoom,'ActionPostCallback',@zoomEnded);
    
%     plot3(Grid(:,1),Grid(:,2),Grid(:,3),'b.');
    axis equal
    
    set(origAxis,'position',[0 0 1 1]);
    
    for i=1:64
%         set(gridAxis(i),'color','none');
        set(gridAxis(i),'units','pixels');
        set(gridAxis(i),'position', [0 0 30 30]);
        set(gridAxis(i),'visible','off');
    end
     
    set(origFig,'userdata',uData);
 
    set(gcf,'currentaxes',origAxis);

    rotate3d(origAxis,'on');

end

function zoomStarted(a,b)
    out = get(a.figure,'userdata');
    [ Grid, origAxis, gridAxis, highHandle, lowHandle] = out{:}
    ShowLowPolyCortex(highHandle, lowHandle);
    HideAxis(a,b);
end
function zoomEnded(a,b)
    out = get(a.figure,'userdata');
    [ Grid, origAxis, gridAxis, highHandle, lowHandle] = out{:};
    ShowHighPolyCortex(highHandle, lowHandle);
    RepositionAxis(a,b);
end

function rotationStarted(a, b)
    out = get(a.figure,'userdata');
    [ Grid, origAxis, gridAxis, highHandle, lowHandle] = out{:};
    ShowLowPolyCortex(highHandle, lowHandle);
    HideAxis(a,b);
end

function rotationDone(a, b)
    out = get(a.figure,'userdata');
    [ Grid, origAxis, gridAxis, highHandle, lowHandle] = out{:};
    ShowHighPolyCortex(highHandle, lowHandle);
    RepositionAxis(a,b);
end

function HideAxis(a,b)
    out = get(a.figure,'userdata');
    [ Grid, origAxis, gridAxis, highHandle, lowHandle] = out{:};
    for i=1:64
        set(get(gridAxis(i),'children'),'visible','off');
    end
end

function RepositionAxis(a,b)
    out = get(a.figure,'userdata');
    [ Grid, origAxis, gridAxis, rcb, zcb] = out{:};
    screenCoords = GetScreenCoordsForPoint(Grid, origAxis);
    for i=1:64
        set(get(gridAxis(i),'children'),'visible','on');
        set(gridAxis(i),'units','pixels');
        set(gridAxis(i),'position',[screenCoords(1,i)-30 screenCoords(2,i)-30 60 60]);
    end
end


function screenCoords = GetScreenCoordsForPoint(points, inAxis)
    % Generate screen coordinates for points (one xyz triplet per row);
    if size(points,2) ~= 3
        error('points - one xyz triplet per row');
    end

    oldUnits = get(inAxis,'units');
    set(inAxis,'units','pixels');
    origAxisPos = get(inAxis,'position');
    if strcmp(get(inAxis,'cameraviewanglemode'),'manual') == 1
        %We're no longer scaling to fit, so need to do some crazy stuffs
        curVA = get(inAxis,'cameraviewangle')
        set(inAxis,'cameraviewanglemode','auto');
        autoVA = get(inAxis,'cameraviewangle');
        set(inAxis,'dataaspectratiomode','auto');
        set(inAxis,'cameraviewangle',curVA);
        zoomRatio = tand(autoVA) / tand(curVA);
        
        scaledAxis = origAxisPos .* [1 1 zoomRatio zoomRatio];
        origAxisCenter = [origAxisPos(1) + origAxisPos(3)/2 origAxisPos(2) + origAxisPos(4)/2];
        scaledAxis(1:2) = [origAxisCenter(1) - scaledAxis(3)/2  origAxisCenter(2) - scaledAxis(4)/2];
        origAxisPos = scaledAxis;
    else
        zoomRatio = 1;
    end
    set(inAxis,'units',oldUnits);
    
    % Now let's get this into 2D Orthogonal
    T = view(inAxis);

    % Get bounding box (for original axis)
    xl=get(gca,'xlim');
    yl=get(gca,'ylim');
    zl=get(gca,'zlim');

    % Construct normalizing matrix
    N=[...
        1/(xl(2)-xl(1)) 0 0 0;...
        0 1/(yl(2)-yl(1)) 0 0;...
        0 0 1/(zl(2)-zl(1)) 0;...
        0 0 0 1;...
    ];

    % Add the normalizing matrix to the view matrix
    T = T * N;

    % Transform the grid coordinates by the view matrix
    Y = T*[points'; ones(1,size(points,1))];

    % Discard Z-coordinate... we can do this because we're in orthogonal view
    % mode. Perspective correction would need another matrix multiplication, but let's
    % ignore that for now

    Y = Y(1:2,:);

    % Make a box out of the bounding box
    box = [...
        xl(1) yl(1) zl(1);...
        xl(1) yl(1) zl(2);...
        xl(2) yl(1) zl(2);...
        xl(2) yl(1) zl(1);...
        xl(1) yl(2) zl(1);...
        xl(2) yl(2) zl(1);...
        xl(2) yl(2) zl(2);...
        xl(1) yl(2) zl(2);...
    ];

    % Do the same transformation on the bounding box
    newBox = T * [box'; ones(1,8)];

    % Discard the Z
    newBox = newBox(1:2,:)';

    boxXLim = [min(newBox(:,1)) max(newBox(:,1))];
    boxYLim = [min(newBox(:,2)) max(newBox(:,2))];

    axisRatio = (boxXLim(2) - boxXLim(1)) / (boxYLim(2) - boxYLim(1));

    aspectRatio = origAxisPos(3) / origAxisPos(4);

    if axisRatio < aspectRatio
        clampedAxis = 'y';
    elseif axisRatio > aspectRatio
        clampedAxis = 'x';
    else
        clampedAxis = 'same';
    end

%     clampedAxis

    normalizedPoint = zeros(size(Y));
    for point = 1:length(Y)
        normalizedPoint(1,point) = (Y(1,point) - boxXLim(1)) / (boxXLim(2) - boxXLim(1));
    end
    for point = 1:length(Y)
        normalizedPoint(2,point) = (Y(2,point) - boxYLim(1)) / (boxYLim(2) - boxYLim(1));
    end
    
    pixelPoint = zeros(size(normalizedPoint));
    switch clampedAxis
        case 'y'
            yPixels = origAxisPos(4);
            xPixels = yPixels * axisRatio;
            xPixelOffset = (origAxisPos(3) - xPixels) / 2;
            for point = 1:length(normalizedPoint)
                pixelPoint(1,point) = normalizedPoint(1,point) * xPixels + xPixelOffset + origAxisPos(1);
            end

            for point = 1:length(normalizedPoint)
                pixelPoint(2,point) = normalizedPoint(2,point) * yPixels  + origAxisPos(2);
            end
        case 'x'
            xPixels = origAxisPos(3);
            yPixels = xPixels / axisRatio;
            yPixelOffset = (origAxisPos(4) - yPixels) / 2;

            for point = 1:length(normalizedPoint)
                pixelPoint(1,point) = normalizedPoint(1,point) * xPixels  + origAxisPos(1);
            end        
            for point = 1:length(normalizedPoint)
                pixelPoint(2,point) = normalizedPoint(2,point) * yPixels + yPixelOffset+ origAxisPos(2);
            end
        case 'same'
            xPixels = origAxisPos(3);
            yPixels = origAxisPos(4);

            for point = 1:length(normalizedPoint)
                pixelPoint(1,point) = normalizedPoint(1,point) * xPixels  + origAxisPos(1);
            end        
            for point = 1:length(normalizedPoint)
                pixelPoint(2,point) = normalizedPoint(2,point) * yPixels+ origAxisPos(2);
            end
    end

    screenCoords = pixelPoint;
    
    axis off;
    
end 