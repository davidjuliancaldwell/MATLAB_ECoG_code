function values = generateLinearClassifierMatrixRealtime(nChans, nBins, xControlChannel, yControlChannel, zControlChannel)
    %% needed variables

    values = zeros((nChans+3)*nBins, 4);
    
%     outputFilepath = 'LinearClassifierMatrix_64.txt';
%     nChans = 64;
%     nBins = 5;
%     xControlChannel = 2;
%     yControlChannel = 5;
%     zControlChannel = 10;

    %% create the output file

%     handle = fopen(outputFilepath, 'w');
% 
%     lineCount = 0;

    % add lines for the x control channel
    for bin = 1:nBins
        values(bin, :) = [xControlChannel, bin, 1, 1];
        values(nBins+bin, :) = [yControlChannel, bin, 2, 1];
        values(2*nBins+bin, :) = [zControlChannel, bin, 3, 1];
    end
    
    for chan = 1:nChans
        for bin = 1:nBins
            values(3*nBins + nBins*(chan-1) + bin, :) = [chan, bin, chan+3, 1];
        end
    end

%     fclose(handle);
% 
%     %% display the result
%     fprintf('Success: %d lines written to %s\n', lineCount, outputFilepath);
end
    