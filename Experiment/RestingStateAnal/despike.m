function [ data_out, outlier_index ] = despike( data_in, rangemultiplier, threshold, sequential )
%DESPIKE Removes spikes by interpolation outside of a range.
%   [DATA_OUT, OUTLIER_INDEX] = DESPIKE(DATA_IN, RANGEMULTIPLIER, THRESHOLD)
%   This function removes data spikes. It first identifies all the spikes
%   outside rangemultiplier*interpercentile_range of the data, with the
%   interpercentile_range being decided by the threshold.
%   Default values for datarange is 10, and threshold is 0.995.
%   
%   Y = DESPIKE(X) outputs the despiked data
%
%   [ Y, OUTLIER_INDEX ] = DESPIKE(X) also outputs the indices
%   of all the data points where the despike identified outliers
%
%   Y = DESPIKE(X, rangemultiplier) identifies outliers outside
%   rangemultiplier * range
%
%   Y = DESPIKE(X, rangemultiplier, threshold) identifies outliers outside
%   rangemultiplier * range, where range is max-min, where max is the
%   top threshold quantile (default 0.995, or 99.5 percentile), and min is
%   1-threshold (default 0.005, or 0.5 percentile)

    if(~exist('rangemultiplier', 'var'))
        rangemultiplier = 2;
    end

    if(~exist('threshold', 'var'))
        threshold = 0.995;
    end

    if(~exist('sequential', 'var'))
        sequential = 3;
    end
    
    data_out = data_in;
    
    % find max, min, range
    rmax = quantile(data_in, threshold); % finds top (99.5) percentile
    rmin = quantile(data_in, 1-threshold); % finds bottom (0.5) percentile
    rrange = rmax - rmin; % finds inter-percentile range
    
    % find outliers
    outliers = data_in > (rmax + rangemultiplier*rrange) | ...
        data_in < (rmin - rangemultiplier*rrange);
                        % outliers are anything outside of 10*(max-min)
    outlier_index = find(outliers);
    
    % find continuous outliers, if more than 3 samples then quit
    outlierjumps = diff(outlier_index);
    if(sum(diff(outlierjumps) == 0))    % if there are sequential outliers
                                        % diff(outlierjumps) would give 0's
                                        % one 0: 2 sequential outliers
                                        % two 0's: 3 sequential outliers
                                        % etc etc.
                                        % Change the > 1 at the
                                        % end if you have a higher
                                        % tolerance for sequential outliers
        warning('More than 2 continuous outlier samples in a row')
        if(sum(diff(outlierjumps) == 0) > (sequential-2)) 
            error(['More than ' num2str(sequential) ' continuous outliers in a row; quitting']);
        end
    end
    
    % find the start and stops of these outliers
    startpoint = find(diff(outliers) == 1); % one sample before the outlier
    stoppoint = find(diff(outliers) == -1) + 1; % one sample after the outlier
    
    if(length(startpoint) ~= length(stoppoint)) % these two should always match
        error('# of outlier starts and stops mismatch for some reason')
    end
    
    for iter = 1:length(startpoint) % now go through all the outliers
        
        startsample = data_in(startpoint(iter)); % value before outlier
        stopsample = data_in(stoppoint(iter)); % value after outlier
        interplength = stoppoint(iter)-startpoint(iter)+1; % # of outlier points + before + after
        
        data_out(startpoint(iter):stoppoint(iter)) = ...
            linspace(startsample, stopsample, interplength);
                % replace the outlier samples with linear interpolation
    end
    
    fprintf('Despike: replaced %d outliers in %d outlier blocks.\n', length(outlier_index), length(startpoint));

end
