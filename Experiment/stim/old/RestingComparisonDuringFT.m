function rs = RestingComparisonDuringFT(ds, doPlots)
    if (nargin < 2)
        doPlots = true;
    end
    
    if (~isstruct(ds))
        error('RestingComparisonDuringFT works on dataset structs, check your arguments.');
    end
    
    for recNum = 1:length(ds.recs)
        rs.results(recNum) = processRecording(ds.recs(recNum));
    end; clear recNum;
    
    if (doPlots == true)
        showResults(ds, rs);
    end
end

function result = processRecording(rec)
    % set up the bad result
    bad.gammas = [];
    
    path = [rec.dir '\' rec.file];
    if (~exist(path, 'file'))
        warning('target recording file does not exist: %s\n', path);
        result = bad;
        return;
    end
    
    [sig, sta, par] = load_bcidat(path);
            
    signals = double(sig);
            
    code = sta.StimulusCode;
                        
    fs = par.SamplingRate.NumericValue;
    gugers = isfield(par,'CommonReference');
            
    montagePath = strrep(path, '.dat', '_montage.mat');
    load(montagePath);
                   
    % process the signal    
    if (~gugers)
        fprintf('Non Guger detected\n');
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    else
        fprintf('Guger detected! Re-referencing each amplifier bank together...\n'); 
        signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
    end
 
    gammaAmps = hilbAmp(signals, [70 200], fs);
%     betaAmps = hilbAmp(signals, [12 18], fs);
    
    code = double(code);
    
    [starts, ends] = getEpochs(code >= 2 & code <= 3, 1);
    
    idxs = mode(ends-starts) ~= (ends-starts);
    starts(idxs) = [];
    ends(idxs) = [];
    
    gammaEpochs = getEpochSignal(gammaAmps, starts, ends);
    result.gammas = squeeze(mean(gammaEpochs,1));
end

function showResults(ds, rs)

    load([ds.surf.dir '\' ds.surf.file]);
    load([ds.trodes.dir '\' ds.trodes.file]);
    
    for trode = 1:64
        for c = 2:4
            vals(trode, c) = signedSquaredXCorrValue(rs.results(c).gammas(trode,:), rs.results(1).gammas(trode,:), 2);
        end
    end
    
    rsas = mean(vals, 2);
    
    
    ctmr_dot_plot(cortex, Grid, rsas, 'r', [-1 1], 20);
end
% function showResults(ds, rs)
% 
%     origFig = figure;
%     origAxis = axes;
%     [highHandle lowHandle] = PlotCortex('junc11','rh','yesimsureiwanttousethelowreshack');
% 
%     load([getSubjDir('junc11') 'trodes.mat']);
%         
%     numChans = size(rs.results(1).gammas,1);
%     
%     
%     for i=1:numChans
%         gridAxis(i) = axes;
%         set(gridAxis(i),'visible','off');
%     end
%     
%     colors = [1 0 0; 0 1 0; 0 0 1];
%     wb = waitbar(0,'Creating Subplots...');
%     for chan=1:numChans
%         stageIdx = 1;
% %         chan
%         axes(gridAxis(chan));
%         set(gridAxis(chan),'visible','on');
%         
%         barVals = zeros(length(rs.results),1);
%         for resNum = 1:length(rs.results)
%             barVals(resNum) = signedSquaredXCorrValue(rs.results(resNum).gammas(chan,:), rs.results(1).gammas(chan,:), 2);
% %             barVals(resNum) = mean(rs.results(resNum).gammas(chan,:));
%         end
%         h = bar(barVals);
%         set(get(h(1), 'BaseLine'), 'LineWidth', 2, 'LineStyle', ':');
%         ylim([-1 1]);
% %         plot(rs.results(1).gammas(chan,:));
% %         set(gridAxis(chan),'ylim', [-10 10]);
%         set(gridAxis(chan),'visible','off');
%         set(get(gridAxis(chan),'children'),'visible','off');
%         waitbar(chan/numChans, wb);
%     end
%     close(wb);
%     
%     uData = {Grid, origAxis, gridAxis, highHandle, lowHandle};
%    
%     set(gcf,'currentaxes',origAxis);
%     hRot = rotate3d(origAxis);
%     hZoom = zoom(origAxis);
%     
%     set(hRot,'ActionPreCallback',@rotationStarted);
%     set(hRot,'ActionPostCallback',@rotationDone);
%     
%     set(hZoom,'ActionPreCallback',@zoomStarted);
%     set(hZoom,'ActionPostCallback',@zoomEnded);
%     
% %     plot3(Grid(:,1),Grid(:,2),Grid(:,3),'b.');
%     axis equal
%     
%     set(origAxis,'position',[0 0 1 1]);
%     
%     for i=1:numChans
% %         set(gridAxis(i),'color','none');
%         set(gridAxis(i),'units','pixels');
%         set(gridAxis(i),'position', [0 0 30 30]);
%         set(gridAxis(i),'visible','off');
%     end
%      
%     set(origFig,'userdata',uData);
%  
%     set(gcf,'currentaxes',origAxis);
% 
%     rotate3d(origAxis,'on');
% 
%     fprintf('ROTATE ME!\n');
% end

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
    for i=1:length(gridAxis)
        set(get(gridAxis(i),'children'),'visible','off');
    end
end

function RepositionAxis(a,b)
    out = get(a.figure,'userdata');
    [ Grid, origAxis, gridAxis, rcb, zcb] = out{:};
    screenCoords = GetScreenCoordsForPoint(Grid, origAxis);
    for i=1:length(gridAxis)
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