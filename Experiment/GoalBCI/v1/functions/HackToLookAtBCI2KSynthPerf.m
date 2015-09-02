ddir = 'd:\temp\goalreplay\d6c834_goal_bci001\';
files = dir(ddir);

for file = files'
    if (~strcmp(file.name, '.') && ~strcmp(file.name, '..'))
        filepath = fullfile(ddir, file.name);
        [~,sta,par] = load_bcidat(filepath);
        
        [~,~,~,~,~,~,fs,fe] = identifyFullEpochs(sta, par);
        targets = double(sta.TargetCode(fe));
        results = double(sta.ResultCode(fe+1));
        keepers = targets ~= 9;
        
        hits = targets(keepers) == results(keepers);
        fprintf('score: %f\n', mean(hits));
    end
end