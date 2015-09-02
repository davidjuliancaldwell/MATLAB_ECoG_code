function y = extractAndWhiten(x, fw, fs, goodChannels)
% function y = extractAndWhiten(x, fw, fs)
%
% performs wavelet decomposition of time series x, using wavelets with
% center frequences in fw.  Normalizes coefficients within each frequency
% and collapses across the entire frequency range.
%
% x - input timeseries, TxC where T is number of samples and C is number of
% channels
%
% fw - wavelet center frequencies
%
% fs - sampling rate of x
% 
% goodChannels (optional) - boolean vector of channels to be processed,
% length C.  If not supplied all channels will be processed.  Unprocessed
% channels will have resultant power values of zero.
%
% y - whitened power estimates, TxC

    if (~exist('goodChannels', 'var'))
        goodChannels = ones(1, size(x,2));
    end
    
    coeffs = zeros(size(x, 1), size(x, 2), length(fw));
    
    for c = 1:size(x,2)
        if (goodChannels(c))
            % perform spectral decomposition
            foo = abs(time_frequency_wavelet(x(:,c), fw, fs, 0, 1, 'CPUtest'));
            coeffs(:,c,:) = foo;
%             [~, ~, coeffs(:, c, :)] = time_frequency_wavelet(x(:,c), fw, fs, 0, 1, 'CPUtest');
        end
    end
    
    % normalize on a frequency by frequency basis
    normCoeffs = zscore(coeffs, 0, 1);
    
    % collapse across all frequencies
    y = mean(normCoeffs, 3);
end