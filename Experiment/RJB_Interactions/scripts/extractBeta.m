function beta = extractBeta(sig, fs, src)
error('doesn''t work');
    X = [];
    for c = 1:size(sig, 2)
        [X(:, c), hz] = pwelch(sig(:,c), fs, fs/2, fs, fs);
    end
    
    plot(hz, log(X)./repmat(mean(log(X), 2), 1, size(X,2)));
end