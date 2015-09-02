function values = generateCARMatrix_toFile(nChans, bads, outputFilepath, doGugerize)
    %% create the output file

    handle = fopen(outputFilepath, 'w');

    if (exist('doGugerize', 'var'))
        values = generateCARMatrix(nChans, bads, doGugerize);
    else
        values = generateCARMatrix(nChans, bads);
    end
    
    for line = 1:size(values,1)
        str = sprintf('%f\t', values(line,:));
        fprintf(handle, [str(1:(end-1)), '\n']);
    end

    fclose(handle);

%     %% display the result
%     fprintf('Success: %d lines written to %s\n', lineCount, outputFilepath);
end