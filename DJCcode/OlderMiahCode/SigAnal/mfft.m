% wrapper for fft to make life easy
function [Y, hz] = mfft(X, dim, fs)      
    if (ndims(X) > 2)
        error('does not work on multi-d arrays with dimensionality greater than 2');
    end
    
    if (~exist('dim','var'))
        dim = 1;
    end
    
    X = shiftdim(X, dim-1);
    
    if (~exist('fs','var'))
        error('sampling frequency must be supplied');
    end
    
    nfft = size(X,1);
    
    Y = fft(X, nfft)/nfft;
    
    if (mod(nfft, 2) == 1)
        hz = fs/2*linspace(0,1,nfft/2+1/2);
        Y = 2*Y(1:nfft/2+1/2, :);
    else
        hz = fs/2*linspace(0,1,nfft/2+1);
        Y = 2*Y(1:nfft/2+1, :);
    end
    
    if (nargout < 1)
%         figure;
        plot(hz, log(abs(Y)));
        xlabel('hz');
        ylabel('power');
    end
    
    Y = shiftdim(Y, dim-1);
end