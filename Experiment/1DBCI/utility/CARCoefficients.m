function coeffs = CARCoefficients(controlChannel, chanCount)

    % error checking
    if (~exist('controlChannel', 'var'))
        warning ('assuming control channel');
    end
    if (~exist('chanCount', 'var'))
        warning ('assuming 64 channels');
    end
    
    if (chanCount < controlChannel)
        error ('control channel %d greater than number of channels in recording: %d', ...
            controlChannel, chanCount);
    end
    
    % actual script
    margin = 1/chanCount;

    coeffs = -margin * ones([chanCount 1]);
    coeffs(controlChannel) = 1 - margin;
    
    % print out results as well as return them
    fprintf('%1.8f\t',coeffs);
    fprintf('\n');
    
end