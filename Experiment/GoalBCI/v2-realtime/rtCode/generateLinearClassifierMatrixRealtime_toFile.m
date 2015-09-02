function values = generateLinearClassifierMatrixRealtime_toFile(nChans, nBins, xControlChannel, yControlChannel, zControlChannel, outputFilepath)
    %% needed variables

    values = generateLinearClassifierMatrixRealtime(nChans, nBins, xControlChannel, yControlChannel, zControlChannel);
    
    %% create the output file

    handle = fopen(outputFilepath, 'w');

    for line = 1:size(values,1)
        str = sprintf('%d\t', values(line,:));
        fprintf(handle, [str(1:(end-1)), '\n']);
    end

    fclose(handle);
    
end
    