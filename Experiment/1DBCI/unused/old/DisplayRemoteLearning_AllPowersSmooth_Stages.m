    function DisplayRemoteLearning_AllPowersSmooth_Stages

    subjectID = 'octb09';
    
    switch subjectID
        case 'jc'
            target = 'jc_mot';
            lowResHack = 1;
            side = 'lh';   
        case 'hh'
            target = 'hh_mot';
            lowResHack = 1;
            side = 'rh';
        case 'jt2'
            target = 'jt2_mot';
            side = 'rh';
            lowResHack = 01 ;
        case 'octb09'
            target = 'octb09_mot';
            side = 'rh';
            lowResHack = 01 ;
        case 'aprb10'
            target = 'aprb10_mot_t';
            side = 'rh';
            lowResHack = 0;
        case 'maya10'
            target = 'maya10_im';
            side = 'rh';
            lowResHack = 0;
        case 'mg'
            target = 'mg_im';
            side = 'lh';
            lowResHack = 1;
        case 'juna09'
            target = 'juna09_im';
            side = 'rh';
            lowResHack = 1;
    end
     
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
    
    
    
    
    if lowResHack == 1
%         [highHandle lowHandle] = PlotCortex('e_octb09',side,'yesimsureiwanttousethelowreshack');

        [highHandle lowHandle] = PlotCortex('fc9643',side,'yesimsureiwanttousethelowreshack');
%         [highHandle lowHandle] = PlotCortex(subjectID,side,'yesimsureiwanttousethelowreshack');
    else
        [highHandle lowHandle] = PlotCortex(subjectID,side);
    end
    load([getSubjDir('fc9643') 'trodes.mat']);
%     load([getSubjDir(subjectID) 'trodes.mat']);
    load(sprintf('%s\\RemoteLearning\\%s.mat',myGetenv('output_dir'),target));
    load d:\research\subjects\fc9643\data\D2\fc9643_ud_im_t001\fc9643_ud_im_tS001R01_montage.mat;
%     load(sprintf('%s\\%s_montage.mat',getSubjDir(['e_' subjectID]),subjectID));
    
    fprintf('Bad electrodes: ');
    fprintf('%i ', Montage.BadChannels)
    fprintf('\n');
    
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
    
    
    % pick out which electrodes we want from the recording
    switch(chosen)
        case trodeIdx
            offsetLoc = 1;
            endLoc = size(allZScores,2);
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
    
    %the important subset is offsetLoc and endLoc
    trodesToDraw = offsetLoc:endLoc;
    
    allZScores = allZScores(:,trodesToDraw);
    electrodeLocs = Montage.MontageTrodes(trodesToDraw,:);
    
    allEpochs(:,1) = cumsum(ones(length(allEpochs),1));
    colors = [1 0 0; 0 1 0; 0 0 1];
%     wb = waitbar(0,'Creating Subplots...');
    chanIdx = 1;
    for chan=1:size(electrodeLocs,1)
        chN = chanIdx;
        gridAxis(chanIdx) = axes;
        stageIdx = 1;
%         chan
%         axes(gridAxis(chan));
%         set(gridAxis(chan),'visible','on');  
                
       f = GaussianSmooth(allZScores(allEpochs(:,6)==2,chan),15);
        stageIdx = 1;
        for stage = stages'
            validEpochs = find(allEpochs(:,6)==2);
            eIndices = validEpochs >= stage(1) & validEpochs <= stage(2);
            validEpochs = validEpochs(eIndices);
            plot(validEpochs,f(eIndices),'linewidth',1,'color','k','linestyle','-');
            hold on;
            stageIdx = stageIdx + 1;
        end
        
        f = GaussianSmooth(allZScores(allEpochs(:,6)==1,chan),15);
        stageIdx = 1;
        for stage = stages'
            validEpochs = find(allEpochs(:,6)==1);
            eIndices = validEpochs >= stage(1) & validEpochs <= stage(2);
            validEpochs = validEpochs(eIndices);
            plot(validEpochs,f(eIndices),'linewidth',2,'color',colors(stageIdx,:));
            hold on;
            stageIdx = stageIdx + 1;
        end


        axis tight;
        plot(get(gca,'xlim'),[0 0],'k-');
        plot(get(gca,'xlim'),[-3 -3],'k:');
        plot(get(gca,'xlim'),[3 3],'k:');
        set(gca,'ylim',[-5 5]);

        set(gridAxis(chanIdx),'visible','off');
        set(get(gridAxis(chanIdx),'children'),'visible','off');
%         waitbar(chan/numChans, wb);

        chanIdx = chanIdx + 1;
    end
%     close(wb);
    
    uData = {electrodeLocs, origAxis, gridAxis, highHandle, lowHandle};
   
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
    
    ff = 1;
    for i=1:size(electrodeLocs,1)
%         set(gridAxis(i),'color','none');
        set(gridAxis(ff),'units','pixels');
        set(gridAxis(ff),'position', [0 0 40 40]);
        set(gridAxis(ff),'visible','off');
        ff = ff + 1;
    end
     
    set(origFig,'userdata',uData);
 
    set(gcf,'currentaxes',origAxis);

    rotate3d(origAxis,'on');

    fprintf('ROTATE ME!\n');
    
%      if lowResHack == 1
%         figure;
%           PlotCortex('fc9643',side,'yesimsureiwanttousethelowreshack');
% %         PlotCortex(subjectID,side,'yesimsureiwanttousethelowreshack');
%         PlotElectrodes('fc9643');
% %         PlotElectrodes(subjectID);
%     else
%         figure;
%         PlotCortex(subjectID,side);
%         PlotElectrodes(subjectID);
%     end
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
        set(gridAxis(i),'position',[screenCoords(1,i)-30 screenCoords(2,i)-30 40 40]);
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