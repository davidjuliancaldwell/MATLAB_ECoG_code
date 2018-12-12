data = rand(10,4,5);
windowSize = 10;
nsegments = 5;
numChans = 4;

% this is my attempt
data_shuffled = zeros(size(data));

for i = 1:numChans
    
    data_shuffled(:,i,:) = data(:,i,randperm(nsegments));
    
end

% compare to shuffling from Kailtny - 2-5-2016

segmented_data = data;

shuffled_indices = randperm(nsegments);

shuffled_segmentedData = segmented_data(:,:,shuffled_indices);
