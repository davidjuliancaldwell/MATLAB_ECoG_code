function PlotCorticalDisplay(subjectID, side, Montage, dataFilesToLoad, callbackFunction, varargin)

    fprintf('Creating plot\n');
    
    origFig = figure;
    origAxis = axes;
    
    
    fprintf('  [Plotting cortex]\n');
    [highHandle lowHandle] = PlotCortex(subjectID,side);

    fprintf('  [Loading electrode positions]\n');
    load([getSubjDir(subjectID) 'trodes.mat']);
    
    fprintf('  [Shared memory init]\n');
    dataReference = c_CortiPlotSharedMemoryObject;
    
    fprintf('  [Loading required files]\n');
    if ~isempty(dataFilesToLoad)
        
        for dataFile = dataFilesToLoad
            dataFile = dataFile{:};
            variables = whos('-file', dataFile);
            for var = variables'
                dataReference.variables.(var.name) = load(dataFile,var.name);
                dataReference.variables.(var.name) = dataReference.variables.(var.name).(var.name);
            end
        end
    end
    
    fprintf('  done!\n\n');
    
    fprintf('Bad electrodes: ');
    fprintf('%i ', Montage.BadChannels)
    fprintf('\n\n');
    
    fprintf('Select which grid to display:\n');
    trodeIdx = 1;
    
    for trode = Montage.MontageTokenized
        parenLoc = find(trode{:}=='(',1,'first');
        if isempty(parenLoc)
            baseName = trode{:};
        else
            baseName = trode{:}(1:parenLoc-1);
        end
        fprintf('  %2i) %s\n', trodeIdx, trode{:});
        trodeIdx = trodeIdx + 1;
    end
    
    fprintf('  %2i) ALL\n', trodeIdx);
    
    fprintf('Choose electrode 1-%i [default %i]\n', trodeIdx, trodeIdx);
    
    chosen = input('=> ');
%     chosen = 2;

    
    if isempty(chosen)
        chosen = trodeIdx;
    end
    
    fprintf('\nGenerating plots\n');
    
    fprintf('  [Identifying required electrodes]\n');
    % pick out which electrodes we want from the recording
    switch(chosen)
        case trodeIdx
            offsetLoc = 1;
            endLoc = sum(Montage.Montage);
%             selectedTrodes = 1:size(AllTrodes,1);
        otherwise
            offsetLoc = 1;
            endLoc = 1;
            parenLoc = find(Montage.MontageTokenized{chosen}=='(',1,'first');
            if isempty(parenLoc)
                selectedBaseName = Montage.MontageTokenized{chosen};
            else
                selectedBaseName = Montage.MontageTokenized{chosen}(1:parenLoc-1);
            end

            for trodesFromMontage = Montage.MontageTokenized      
                parenLoc = find(trodesFromMontage{:}=='(',1,'first');
                if isempty(parenLoc)
                    montageTrodeBaseName =trodesFromMontage{:};
                    numbers = ':';
                else
                    montageTrodeBaseName = trodesFromMontage{:}(1:parenLoc-1);
                    closeParenLoc = find(trodesFromMontage{:}==')',1,'last');
                    
                    numbers = trodesFromMontage{:}(parenLoc:closeParenLoc);
                end
                
                if strcmp(numbers,'(:)') == 1
                    numbers = ':';
                end
                
                
                if strcmp(selectedBaseName,montageTrodeBaseName) == 1
                    eval(sprintf('endLoc = offsetLoc + size(%s(%s,1),1)-1;',montageTrodeBaseName, numbers));
                    break;
                end
                eval(sprintf('offsetLoc = offsetLoc + size(%s(%s,1),1);',montageTrodeBaseName, numbers));
            end
    end
    
    fprintf('  [Executing plotting callback]\n');
    
    %the important subset is offsetLoc and endLoc
    trodesToDraw = offsetLoc:endLoc;
    electrodeLocs = Montage.MontageTrodes(trodesToDraw,:);
    for plotNum=1:size(electrodeLocs,1)
        gridAxis(plotNum,1) = axes;
        
        %callback function!
        gridAxis(plotNum,2) = callbackFunction(gridAxis(plotNum), offsetLoc+plotNum-1,plotNum, dataReference, ~isempty(find(Montage.BadChannels == offsetLoc+plotNum-1, 1)), varargin);
        
        set(gridAxis(plotNum),'visible','off');
        set(get(gridAxis(plotNum),'children'),'visible','off');
        set(gridAxis(plotNum),'units','pixels');
        set(gridAxis(plotNum),'position', [0 0 40 40]); % 40 40
    end
    
    fprintf('  [Setting rotation callbacks]\n');
    
    uData = {electrodeLocs, origAxis, gridAxis, highHandle, lowHandle};
   
    set(gcf,'currentaxes',origAxis);
    
    hRot = rotate3d(origAxis);
    hZoom = zoom(origAxis);
%     hPan = pan(origFig);
    
    set(hRot,'ActionPreCallback',@rotationStarted);
    set(hRot,'ActionPostCallback',@rotationDone);
    
    set(hZoom,'ActionPreCallback',@zoomStarted);
    set(hZoom,'ActionPostCallback',@zoomEnded);
    
%     set(hPan,'ActionPreCallback',@panStarted);
%     set(hPan,'ActionPostCallback',@panDone);
    
    axis equal
    
    set(origAxis,'position',[0 0 1 1]);
    
    set(origFig,'userdata',uData);
 
    set(gcf,'currentaxes',origAxis);

    rotate3d(origAxis,'on');

    fprintf('  done!\n');
    
    fprintf('ROTATE ME!\n');
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

% function panStarted(a, b)
%     out = get(a.figure, 'userdata');
%     [ Grid, origAxis, gridAxis, highHandle, lowHandle] = out{:};
%     ShowLowPolyCortex(highHandle, lowHandle);
%     HideAxis(a,b);
% end
% 
% function panDone(a, b)
%     out = get(a.figure, 'userdata');
%     [ Grid, origAxis, gridAxis, highHandle, lowHandle] = out{:};
%     ShowHighPolyCortex(highHandle, lowHandle);
%     RepositionAxis(a,b);    
% end

function HideAxis(a,b)
    out = get(a.figure,'userdata');
    [ Grid, origAxis, gridAxis, highHandle, lowHandle] = out{:};
    for i=1:length(gridAxis)
        set(gridAxis(i,1),'visible','off');
        set(get(gridAxis(i,1),'children'),'visible','off');
    end
end

function RepositionAxis(a,b)
    out = get(a.figure,'userdata');
    [ Grid, origAxis, gridAxis, rcb, zcb] = out{:};
    screenCoords = GetScreenCoordsForPoint(Grid, origAxis);
    for i=1:length(gridAxis)
        set(get(gridAxis(i,1),'children'),'visible','on');
        if gridAxis(i,2) == 1
            set(gridAxis(i,1),'visible','on');
        end
        set(gridAxis(i,1),'units','pixels');
%         set(gridAxis(i,1),'position',[screenCoords(1,i)-30 screenCoords(2,i)-30 40 40]);
        set(gridAxis(i,1),'position',[screenCoords(1,i)-30 screenCoords(2,i)-30 80 80]);
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