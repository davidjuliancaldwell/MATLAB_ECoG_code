function [number, vector, string] = extractRecordingDate(par)
    str = par.StorageTime.Value{:};
    vector = datevec(str, 'ddd mmm dd HH:MM:SS yyyy'); % this may fail for different versions of bci2000
    number = datenum(vector);
    
    string = datestr(number, 'ddd mmm dd HH:MM:SS yyyy');
%     fprintf('%s\n', string);
end