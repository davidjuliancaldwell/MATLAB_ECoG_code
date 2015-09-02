 %% part 1

directory = 'G:\clinical data\beck';

contents = dir(directory);

count = 1;
clear edfnames edfdates;

for c = 1:length(contents)
    if(strendswith(contents(c).name, '.rec') || strendswith(contents(c).name, '.edf'))
        edfnames{count} = [directory '\' contents(c).name];
        edf = sdfopen(edfnames{count}, 'r', 1);
        edfdates(count) = datenum(edf.T0);
        edfdatevecs(count,:) = edf.T0;
        sdfclose(edf);
        
        count = count + 1;
    end
end; clear c; clear count;

sorteddates = sort(edfdates);

%% part 2

lastday = 0; % before
daynum = 1; % before first day
partnum = 0; % before first part

for c = 1:length(sorteddates)
    idx = find(edfdates == sorteddates(c));
%     fprintf('index is %d\n', idx);
    
    temp = datevec(edfdates(idx));
    temp(4:6) = 0;
    temp = datenum(temp);
    
    if (temp == lastday)
        partnum = partnum + 1;
    else
        % new day
        lastday = temp;
        
        daynum = daynum + 1;
        partnum = 1;        
    end
    
    old = edfnames{idx};
    new = [directory '\' sprintf('day%d_part%d.rec', daynum, partnum)];
    
%     movefile(old, new);
    fprintf('would rename %s to %s\n', old, new);    
end


