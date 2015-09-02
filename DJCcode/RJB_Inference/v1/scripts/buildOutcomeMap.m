function [pNorm, pSuccess, finalDistance, handle] = buildOutcomeMap(paths, tgts, ress, t)
    DISTANCE_DISC_FAC = 10;
    
    dDist = 1 / DISTANCE_DISC_FAC;
    distanceAxis = 0:dDist:1;
    
    % time x distance from target success probability map
    ntargets = length(unique(tgts));
    
    % assume that the target space is evenly divided among the targets
    targetExtents = zeros(2, ntargets);
    
    for c = 1:ntargets
        targetExtents(1, c) = (1/ntargets) * (c-1);
    end
    
    targetExtents(2, 1:(end-1)) = targetExtents(1, 2:end);
    targetExtents(2, end) = 1;
    targetExtents = targetExtents(:, end:-1:1);
    
    nThere = zeros(length(distanceAxis), size(paths, 2));
    nHit = nThere;
    finalDistance = zeros(size(tgts));
    
    distanceIndices = zeros(size(paths));
    
    % calculate p(success | distance, time)
    for trial = 1:length(tgts)
        extent = targetExtents(:, tgts(trial));
        distance = min(abs(paths(trial,:)-extent(1)), abs(paths(trial,:)-extent(2)));
        distance(paths(trial, :) >= extent(1) & paths(trial, :) <= extent(2)) = 0;    
        distanceAsIndex = round(distance / dDist) + 1;
        
        % save for later
        distanceIndices(trial, :) = distanceAsIndex;        
        finalDistance(trial) = distance(end);
        
        for time = 1:size(paths, 2)
            nThere(distanceAsIndex(time), time) = nThere(distanceAsIndex(time), time) + 1;
            if (tgts(trial) == ress(trial))
                nHit(distanceAsIndex(time), time) = nHit(distanceAsIndex(time), time) + 1;
            end
        end
    end
    
    % let's fix the nans that have values below them    
    pNorm = nHit ./ nThere;
    
    for x = size(pNorm, 1):-1:1
        if (x == size(pNorm, 1))
            % replace nan's with zeros
            pNorm(x, isnan(pNorm(x, :))) = 0;            
        else
            % replace with the value below
            pNorm(x, isnan(pNorm(x, :))) = pNorm(x+1, isnan(pNorm(x, :)));
        end
    end
    
    % lastly, go back through the paths and assign success probabilities at
    % every given point    
    pSuccess = zeros(size(distanceIndices));
    
    for trial = 1:size(distanceIndices, 1)
        for time = 1:size(distanceIndices, 2)
            pSuccess(trial, time) = pNorm(distanceIndices(trial, time), time);
        end
    end
    
    % then make a figure
    handle = figure;

    subplot(211);
    surf(distanceAxis, t, pNorm');
    shading interp
    view(90,90);
%     imagesc(t, distanceAxis, pNorm); axis xy;

    colorbar;
    xlabel('time (s)');
    ylabel('distance (norm-units)');
    title(sprintf('success probability map, ntargets = %d', ntargets));        
    ylim([0 0.55]);
    
    subplot(212);
    surf(t, distanceAxis, nThere); axis xy;
    imagesc(t, distanceAxis, nThere); axis xy;
    colorbar;
    xlabel('time (s)');
    ylabel('distance (norm-units)');
    title('distance-time histogram');
    ylim([0 0.55]);
    set(gca, 'clim', [0 max(max(nThere(2:end,:)))])
end