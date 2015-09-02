function data = parseLog(logfilePath)
    handle = fopen(logfilePath,'r');

    line = fgetl(handle);

    data = [];

    while line > 0

        temp = regexp(line, '.*?ess: ([0-9\. ]+).', 'tokens');

        if (~isempty(temp))
            data(end+1,:) = sscanf(temp{1}{1}, '%f %f %f %f');
        end

        % get a new line
        line = fgetl(handle);
    end

    fclose(handle);
end

