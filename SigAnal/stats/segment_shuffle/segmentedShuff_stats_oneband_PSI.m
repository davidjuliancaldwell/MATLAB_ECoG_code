function [ real_PSI, masked_bymax, masked_by_pmax ] = segmentedShuff_stats_oneband_PSI( power, bandlimits, windowSize, numReps )

numChans = size(power,2);

newLength = size(power,1) - mod(size(power,1), windowSize);%cut it to even

power = power(1:newLength, :);
numSamps = size(power,1);

nsegments = numSamps/windowSize; % number of segments over which PSI is computed

%% first the actual values

segmented_data = zeros(windowSize, numChans, nsegments);

for segment = 1:nsegments;
    segmented_data(:,:,segment) = power(1:windowSize,:);
    power(1:windowSize, :) = [];
end

segPSI = zeros(size(power,2), size(power,2), 0);

for segment = 1:nsegments;
    
    thisWindow = segmented_data(:,:,segment);
%     thisWindowPSI = PSI_revised(thisWindow);
    thisWindowPSI = data2psi(thisWindow, windowSize/8, windowSize/4, bandlimits);

    segPSI = cat(3, segPSI, thisWindowPSI);
    
end

% std_dev = std(segPSI, 0, 3);
%
% tmeans=(mean(segPSI,3))./std_dev;
% from the original differences script - may want to use this later, but not now

real_PSI = mean(segPSI,3);

%% now the segment shuffling procedure

npairs=(numChans^2-numChans)/2; % number of pairs

tic

max_histogram=zeros(numReps,1);
shuffled_allPSI = zeros(numChans,numChans,numReps);

for i=1:numReps;
    
    shuffled_indices = zeros(numChans, numChans, nsegments);
    for chanA = 1:numChans;
        for chanB = 1:numChans;
            shuffled_indices(chanA, chanB,:)=randperm(nsegments);
        end
    end
    
    shuffled_segmentedData = segmented_data(shuffled_indices);
    
    for segment = 1:nsegments;
        
        thisWindow = shuffled_segmentedData(:,:,segment);
        thisWindowPSI = data2psi(thisWindow, windowSize/8, windowSize/4, bandlimits);
        
        shuffled_segPSI = cat(3, segPSI, thisWindowPSI);
        
    end
    shuffled_allPSI(:,:,i) = mean(shuffled_segPSI,3);
    
    shuffled_segPSI(shuffled_segPSI==1) = 0;
    
    %     t_perm=mean(Ap,3)./std_dev;
    temp = mean(shuffled_segPSI,3);
    max_histogram(i)=prctile(reshape(temp, numChans*numChans,1),95);
    %         min_histogram(i)=min(shuffled_allPSI(:));
end

toc

realPSI_reshape = reshape(real_PSI, numChans*numChans, 1);
p_max=sum(repmat(realPSI_reshape,1,numReps)<repmat(max_histogram',numChans*numChans,1),2)/numReps;

p_max = reshape(p_max, numChans, numChans);


masked_by_pmax = NaN(numChans, numChans);
for i = 1:numChans;
    for j=1:numChans;
        if p_max(i,j)<=0.05;
            masked_by_pmax(i,j) = real_PSI(i,j);
        end
    end
end


cutoffval = mean(max_histogram);

masked_bymax = NaN(numChans, numChans);
for i = 1:numChans;
    for j=1:numChans;
        if real_PSI(i,j)>cutoffval;
            masked_bymax(i,j) = real_PSI(i,j);
        end
    end
end



end

