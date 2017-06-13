function output=rereference_CAR_median(data,mode,bad_channels,permuteOrder)
% DJC 6-12-2017. Function to either common average, or median rereference,
% while excluding bad channels.
%
% data is either time x channels, or time x channels x trials
% bad_channels is a list of bad channels as output
% leaves output channels that are "bad" untouched
% permute is order if need to permute, like [1 3 2]


if (~exist('bad_channels','var'))
    bad_channels = 0;
end

if (~exist('permuteOrder','var'))
    permuteOrder = [1:ndims(data)];
end

data = permute(data,permuteOrder);

output = data;

channel_mask = logical(ones(size(data,2),1));
channel_mask(bad_channels) = 0;

switch(mode)
    case 'mean'
        avg = mean(data(:,channel_mask,:),2);
        avg = repmat(avg, 1, size(data(:,channel_mask,:),2));
        output(:,channel_mask,:) = data(:,channel_mask,:) - avg;
        
        % shift data if needed
        output = permute(output,permuteOrder);
    case 'median'
        med = median(data(:,channel_mask,:),2);
        med = repmat(med, 1, size(data(:,channel_mask,:),2));
        output(:,channel_mask,:) = data(:,channel_mask,:) - med;
        
        % shift data if needed
        output = permute(output,permuteOrder);
end