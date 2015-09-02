% function values = generateMultibandLinearClassifierMatrixRealtime_toFile(nChans, nBins, xControlChannel, yControlChannel, zControlChannel, outputFilepath)
    %% needed variables
    outputFilepath = 'linearClassifier_multiband.txt';
    
    addpath ../functions;
    Constants;
    nChans = 64;
    bins = 3:3:99;
    binis = zeros(size(bins));
    
    for bandIdx = 1:size(BANDS, 1)
        binis(bins > BANDS(bandIdx, 1) & bins <= BANDS(bandIdx, 2)) = bandIdx;
    end
    
    ctlbin =5;
    
    values = generateMultibandLinearClassifierMatrixRealtime(nChans, binis, ctlbin, 1, 12, 1);
        
    %% create the output file

    handle = fopen(outputFilepath, 'w');

    for line = 1:size(values,1)
        str = sprintf('%d\t%d\t%d\t%f', values(line,:));
        fprintf(handle, [str(1:(end-1)), '\n']);
    end

    fclose(handle);
    
% end
    