handle = fopen('spew.txt','r');

line = fgetl(handle);

sfeatures = [];
slabels = [];
sprobabilities = [];

counter = 1;
spewfeatures{counter} = [];

while line > 0
    
    if (strfind(line, 'features'))
        temp = regexp(line, '.*?\]: ([0-9\. ]+).', 'tokens');
        sfeatures(:,end+1) = sscanf(temp{1}{1}, '%f %f %f %f');                       
    elseif (strfind(line, 'classified'))
        temp = regexp(line, 'the target as ([01]) with a posterior of ([0-9\.]*).', 'tokens');
        slabels(end+1) = str2num(temp{1}{1});
        sprobabilities(end+1) = str2num(temp{1}{2});
    end
    
    % get a new line
    line = fgetl(handle);
end

fclose(handle);

