function result = bciSummary(subjid)
    base = getSubjDir(subjid);
    result = [];
    result = findFiles(base, result);
    
    fprintf('\n\n %d total files processed for %s\n', result.filesProcessed, subjid);
    fprintf('  for overt 2 target trials (%d):\n', sum(result.type==0));
    fprintf('    there were %d hits (%d, %d) and %d misses (%d, %d) [up, down]\n\n', ...
                   sum(result.uphits(result.type==0)) + sum(result.downhits(result.type==0)), ...
                   sum(result.uphits(result.type==0)), ...
                   sum(result.downhits(result.type==0)), ...
                   sum(result.upmisses(result.type==0)) + sum(result.downmisses(result.type==0)), ...
                   sum(result.upmisses(result.type==0)), ...
                   sum(result.downmisses(result.type==0)));

    fprintf('  for imagined 2 target trials (%d):\n', sum(result.type==1));
    fprintf('    there were %d hits (%d, %d) and %d misses (%d, %d) [up, down]\n\n', ...
                   sum(result.uphits(result.type==1)) + sum(result.downhits(result.type==1)), ...
                   sum(result.uphits(result.type==1)), ...
                   sum(result.downhits(result.type==1)), ...
                   sum(result.upmisses(result.type==1)) + sum(result.downmisses(result.type==1)), ...
                   sum(result.upmisses(result.type==1)), ...
                   sum(result.downmisses(result.type==1)));
               
    fprintf('  non-direction specific, control mode summary:\n');
    fprintf('    %d trials, %d uphits, %d upmisses, %d downhits, %d downmisses\n\n', ...
                   sum(result.type==0 | result.type==1), ...
                   sum(result.uphits(result.type==0)) + sum(result.uphits(result.type==1)), ...
                   sum(result.upmisses(result.type==0)) + sum(result.upmisses(result.type==1)), ...
                   sum(result.downhits(result.type==0)) + sum(result.downhits(result.type==1)), ...
                   sum(result.downmisses(result.type==0)) + sum(result.downmisses(result.type==1)));
end

function result = findFiles(base, result)
    files = dir(base);
    
    for c = 1:length(files)
        file = files(c);
        path = fullfile(base, file.name);
        
        if (strcmp(file.name, '.') == 0 && strcmp(file.name, '..') == 0)
            if (file.isdir == true)
                result = findFiles(path, result);
            elseif (strendswith(file.name, '.dat'))
                if (~isempty(strfind(file.name, 'ud')))
                    result = processFile(path, result);
                end
            end
        end
    end
end

function result = processFile(file, oresult)

    [~, name, ~] = fileparts(file);
    
    result = oresult;
    
    if(isfield(oresult, 'filesProcessed'))
        result.filesProcessed = oresult.filesProcessed + 1;
    else
        result.filesProcessed = 1;
    end

    if (~isempty(strfind(name, 'targ')))
        result.type(result.filesProcessed) = 2; % multitarg  
    elseif (~isempty(strfind(name, 'mot')))
        result.type(result.filesProcessed) = 0; % mot
    elseif (~isempty(strfind(name, 'im')))
        result.type(result.filesProcessed) = 1; % im
    else
        result.type(result.filesProcessed) = 3; % unknown
    end


    [~, states, ~] = load_bcidat(file);
    
    plotBCIStates(states);
    title(name);
    
    result.uphits(result.filesProcessed) = countUphits(states);
    result.upmisses(result.filesProcessed) = countUpmisses(states);
    result.downhits(result.filesProcessed) = countDownhits(states);
    result.downmisses(result.filesProcessed) = countDownmisses(states);
        
    fprintf('file: %s\n', file);
end

function hits = countUphits(states)
    hits = counthits(states, 1);
end

function hits = countDownhits(states)
    hits = counthits(states, 2);
end

function misses = countUpmisses(states)
    misses = countmisses(states, 1);
end

function misses = countDownmisses(states)
    misses = countmisses(states, 2);
end

function hits = counthits(states, target)
    bools = states.ResultCode == states.TargetCode & states.TargetCode == target;
    ddubs = diff(bools) > 0;
    
    hits = sum(ddubs);
end

function misses = countmisses(states, target)
    bools = states.ResultCode & states.ResultCode ~= states.TargetCode & states.TargetCode == target;
    ddubs = diff(bools) > 0;
    
    misses = sum(ddubs);
end