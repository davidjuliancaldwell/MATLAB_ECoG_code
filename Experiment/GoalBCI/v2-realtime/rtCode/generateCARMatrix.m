function values = generateCARMatrix(nChans, bads, doGugerize)
    if (~exist('doGugerize', 'var'))
        doGugerize = true;
    end
    
    %% needed variables

    % nChans = 64;
    % bads = [15 16];

%     if (isempty(bads))
%         badString = 'none';
%     else
%         badString = sprintf('-%d',bads);
%         badString = badString(2:end);
%     end
% 
%     outputFilepath = sprintf('GugerCAR_%d_%s.txt', nChans, badString);

    %% create the output file
    
%     handle = fopen(outputFilepath, 'w');
    if (doGugerize)
        subMontages = GugerizeMontage(nChans);
    else
        subMontages = nChans;
    end

    endChans = cumsum(subMontages);
    startChans = [1 endChans(1:(end-1))+1];

%     lineCount = 0;

    values = zeros(nChans);
    
    for subMontageIdx = 1:length(subMontages)
        subChannels = startChans(subMontageIdx):endChans(subMontageIdx);
        subBadChannels = ismember(subChannels, bads);
        subNGoodChannels = sum(~subBadChannels);

        big = 1 - 1/subNGoodChannels;
        small = - 1/subNGoodChannels;

        for channelInMontage = 1:subMontages(subMontageIdx)
%             values(subChannels(channelInMontage), :) = zeros(nChans, 1);            
            if (subBadChannels(channelInMontage))
                values(subChannels(channelInMontage), :) = 0;
            else
                values(subChannels(channelInMontage), subChannels) = small;
                values(subChannels(channelInMontage), subChannels(channelInMontage)) = big;
                values(subChannels(channelInMontage), bads) = 0;                
            end
            
%             str = sprintf('%f\t', values);
%             fprintf(handle, [str(1:(end-1)), '\n']);
%             lineCount = lineCount + 1;
        end
    end

%     fclose(handle);

%     %% display the result
%     fprintf('Success: %d lines written to %s\n', lineCount, outputFilepath);
end