handle = fopen('spew.txt','r');

line = fgetl(handle);

spewresults = {};
spewfeatures = {};

counter = 1;
spewfeatures{counter} = [];

while line > 0
    
    if (strfind(line, 'Warning'))
        temp = regexp(line, '.*?\]: ([0-9\. ]+).', 'tokens');
        spewresults{counter} = sscanf(temp{1}{1}, '%f %f %f %f');
        line = fgetl(handle); % throw away
        counter = counter + 1;
        spewfeatures{counter} = [];
    else
        % process
        spewfeatures{counter}(:,end+1) = sscanf(line, '%f %f %f %f.');
    end
    
    % get a new line
    line = fgetl(handle);
end

fclose(handle);

% cleanup
if (isempty(spewfeatures{end}))
    spewfeatures = spewfeatures(1:(end-1));
end

%% now do some verification
for c = 1:length(spewfeatures)
    mfeat = spewfeatures{c};
    mres = spewresults{c};
    
    [mean(mfeat, 2) mres]
end
