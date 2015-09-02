function result = nanify(input, upsamples, downsamples)
% this function takes the vector 'input' and changes a portion of the
% values to NaNs.  if upsamples + downsamples represents one period then
% samples from 1:upsamples will be left alone and upsamples+1 :
% (upsamples+downsamples) will be set to NaN.  This functionality will
% repeat for all samples within input

    result = input;
    
    periodLength = upsamples+downsamples;
    
    idxs = 1:periodLength:length(result);
    
    for idx = idxs
       changestart = idx+upsamples;
       changeend = idx+upsamples+downsamples-1;
       
       if (changestart < length(result))
           if (changeend < length(result))
               result(changestart:changeend) = NaN;
           else
               result(changestart:end) = NaN;
           end
       end
    end
end