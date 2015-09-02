% time of day is a struct with *.H *.M *.S files
% remember that edf's have a status channel at channel 1, so typically grid
% channels are 2:65
function [clinicalData, fs] = getClinicalData(clinicalFilename, timeOfDay, numberOfSeconds, channels)
    if (~exist(clinicalFilename, 'file'))
        error('target clinical file: %s does not exist\n', clinicalFilename);
    end
    
    if (~isstruct(timeOfDay) || ~isfield(timeOfDay, 'H') || ~isfield(timeOfDay, 'M') || ~isfield(timeOfDay, 'S'))
        error('timeOfDay must be a struct with fields H, M, S');
    end
    
    if (~exist('channels', 'var'))
        EDF = sdfopen(clinicalFilename, 'r');
    else
        EDF = sdfopen(clinicalFilename, 'r', channels);
    end
    
    fs = round(mode(EDF.SampleRate));
    
    if (std(EDF.SampleRate) > 1e-3)
        warning('it looks like various channels of the EDF file were recorded at different sampling frequencies\n');
    end
    
    timeOfDayInSeconds = timeOfDay.H * 3600 + timeOfDay.M * 60 + timeOfDay.S;
    recStartInSeconds = EDF.T0(4) * 3600 + EDF.T0(5) * 60 + EDF.T0(6);
    
    startOffset = timeOfDayInSeconds - recStartInSeconds;
    
    if (startOffset < 0)
        warning('requested time of day that precedes the beginning of EDF file.  Truncating clinicalData');
        startOffset = 0;
    end
    
    if (timeOfDayInSeconds + numberOfSeconds > EDF.NRec)
        warning('requested number of samples exceeds end of EDF file.  Truncating clinicalData\n');
        numberOfSeconds = EDF.NRec - timeOfDayInSeconds;
    end
    
    clinicalData = sdfread(EDF, numberOfSeconds, startOffset);
    sdfclose(EDF);
end