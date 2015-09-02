
clear;
fig_setup;

num = 7;

subjid = subjids{num};
id = ids{num};
% clear num;

[files, side, div] = getBCIFilesForSubjid(subjid);

fprintf('running analysis for %s\n', subjid);

for c = 1:length(files)
    
    fprintf('  processing file %d\n', c);

    file = files{c};
    [~, sta, ~] = load_bcidat(file);
    alltgts=sta.TargetCode(diff(double(sta.TargetCode)) ~= 0);
    allress=sta.ResultCode(diff(double(sta.ResultCode)) ~= 0);
    alltgts(alltgts==0) = [];
    allress(allress==0) = [];
    
    fprintf('%d ', alltgts);
    fprintf('\n');
    fprintf('%d ', allress);
    fprintf('\n');
    
%     alltgts'
    
end

