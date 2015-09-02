handle = fopen('spew.txt','r');

line = fgetl(handle);

spewresults = {};
spewfeatures = {};

counter = 1;
spewfeatures{counter} = [];

while line > 0
    
    if (strfind(line, 'Warning'))
        temp = regexp(line, '.*?Value: ([0-9\. ]+).', 'tokens');
        spewresults{counter} = sscanf(temp{1}{1}, '%f');
        line = fgetl(handle); % throw away
        counter = counter + 1;
        spewfeatures{counter} = [];
    end
    
    % get a new line
    line = fgetl(handle);
end

fclose(handle);

sall = [spewresults{:}];

clearvars -except sall