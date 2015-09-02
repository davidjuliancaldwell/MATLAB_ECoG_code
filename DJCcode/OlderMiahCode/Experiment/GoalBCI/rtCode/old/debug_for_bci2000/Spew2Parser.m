handle = fopen('spew2.txt','r');

line = fgetl(handle);

sfeats = [];

while line > 0
    
    temp = regexp(line, '.*?ess: ([0-9\. ]+).', 'tokens');
    sfeats(end+1,:) = sscanf(temp{1}{1}, '%f %f %f %f');
    
    % get a new line
    line = fgetl(handle);
end

fclose(handle);