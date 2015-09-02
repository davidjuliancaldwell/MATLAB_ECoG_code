function [amp, phase] = hilbAmp(signal, fband, fs)
% function hpwr = HilbAmp(signal, fband)
% signal is MxN where M is samples and N is channels
% fband is [x y] where x and y define a band over which to observe the hilb
% power
% fs is sampling rate

    if (size(squeeze(signal),3) > 1)
        error('cannot process multidimensional signal matrix');
    end
    
    if (~exist('fband', 'var'))
        fband = [0 Inf];
    else
        if (length(fband) ~= 2)
            error('fband must be vector of length 2');
        end
        
        if (fband(1) >= fband(2))
            error('first element of fband must be lower than second element');
        end
        
        if (~exist('fs', 'var'))
            error('cannot filter signal to fband without fs');
        else
            if (fband(2) > fs / 2)
                warning('upper value of fband above nyquist, setting to nyquist');
                fband(2) = fs/2;
            end
        end
    end
    
    if (fband(1) > 0)
        if (fband(2) < Inf)
            % bandpass
            signal = bandpass(signal, fband(1), fband(2), fs, 4);
        else
            % highpass only
            signal = highpass(signal, fband(1), fs, 4);
        end
    else
        if (fband(2) < Inf)
            % lowpass only
            signal = lowpass(signal, fband(2), fs, 4);
        else
            % no filtering necessary
        end
    end
    
    result = hilbert(signal);
    
    amp = abs(result);
    phase = angle(result);
end

