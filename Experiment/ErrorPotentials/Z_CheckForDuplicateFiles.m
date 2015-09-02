%% prep
sid = '30052b';
files = listDatFiles(sid, '_ud');
data = cell(length(files), 1);

%% load

for idx = 1:length(files)
    fprintf('%d of %d\n', idx, length(files))
    [sig, ~, ~] = load_bcidat(files{idx});
    data{idx} = sig(1:1000,1);
end

%% test

rs = zeros(length(files)) * NaN;

for idx = 1:length(files)
    for idx2 = (idx+1):length(files)  
        fprintf('trying: %d, %d\n', idx, idx2);
        rs(idx, idx2) = corr(double(data{idx}), double(data{idx2}));  
    end
end

%% display
imagesc(rs);
xlabel('idx');
ylabel('idx2');
colorbar;