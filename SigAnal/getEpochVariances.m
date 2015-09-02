%% getEpochVairances.m

function epochVariances = getEpochVariances(signal, starts, ends)
    if(length(starts) ~= length(ends))
        error('starts and ends must be of same length');
    end

    if (isempty(starts))
        epochVariances = [];
        return;
    end
    
    epochVariances = zeros(size(signal,2), length(starts));
    
    for c = 1:length(starts)
        epochVariances(:,c) = var(signal(starts(c):ends(c)-1,:), 1);
    end; clear c;
end