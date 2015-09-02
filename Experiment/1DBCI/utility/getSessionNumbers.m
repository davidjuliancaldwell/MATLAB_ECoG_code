function sessionNumbers = getSessionNumbers(files)

    sessionNumbers = zeros(size(files));
    sessionCounter = 0;
    prevTime = -Inf;
    
    for c = 1:length(files)
        [~,~,par] = load_bcidat(files{c});
        
        try
            curTime = datenum(par.StorageTime.Value{:}, 'ddd mmm dd HH:MM:SS yyyy');
        catch
            curTime = datenum(par.StorageTime.Value{:}, 'yyyy-mm-ddTHH:MM:SS');
        end        
        
        if (curTime - prevTime > 1/3)
            sessionCounter = sessionCounter + 1;
            prevTime = curTime;
        end
        
        sessionNumbers(c) = sessionCounter;
    end

end