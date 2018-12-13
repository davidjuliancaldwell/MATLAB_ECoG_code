function stru = parseTDTNotes(str)
    StoreNames = regexp(str, 'NAME=StoreName;.*?VALUE=(.*?);', 'tokens');
    NChans = regexp(str, 'NAME=NumChan;.*?VALUE=(.*?);', 'tokens');
    SampleFreqs = regexp(str, 'NAME=SampleFreq;.*?VALUE=(.*?);', 'tokens');
    
    if (length(StoreNames) ~= length(NChans) || length(NChans) ~= length(SampleFreqs))
        error('problem parsing TDT notes string');
    end
    
    L = length(StoreNames);
    
    for c = 1:L
        stru(c).name = StoreNames{c}{1};
        stru(c).nchans = str2double(NChans{c}{1});
        stru(c).fs = str2double(SampleFreqs{c}{1});
    end
end