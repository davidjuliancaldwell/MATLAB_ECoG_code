function averages = windowedAverage(signals, windowLength)
% function averages = windowedAverage(signals, windowLength)
% 
% signals an MxN matrix where M is sample count and N is channel count
% returns a windowed average of size MxN 

%     if (sum(sum(isnan(signals))) > 0)
        fprintf('has NaN''s\n');
        
        averages = zeros(size(signals));
        
        for d = 1:size(signals,1)
            start = max(1, d-windowLength);
            
            nans = isnan(signals(start:d, :));
            realsigs = signals(start:d, :);
            realsigs(nans) = 0;
            counts   = sum(~nans, 1);
            
            % what if it's all nans?
%             realsigs(:, counts == 0) = 0;
%             counts(counts == 0) = 1;
            
            averages(d,:) = sum(realsigs) / counts;
        end
        
%     else
%         fprintf('NaN free\n');
%         
%         window = ones(windowLength, 1)/windowLength;
%         
%         averages = zeros(size(signals));
%         
%         for c = 1:size(signals,2)
%             res = conv(signals(:,c), window);
%             averages(:,c) = res(1:size(signals,1));
%         end
%     end
end
