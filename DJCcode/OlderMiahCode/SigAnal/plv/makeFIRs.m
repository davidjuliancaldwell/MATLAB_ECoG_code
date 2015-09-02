
% script to make fir filters and save them to disk to save computation time

% integer filters, starting at 12 Hz going to 200 Hz
clear;
fs = 2000;
filterFrequencies = 12:200;

% as = zeros(size(filterFrequencies));
% bs = zeros(size(filterFrequencies));

for f = filterFrequencies
    fprintf('making filter for %d Hz', f);
    idx = find(filterFrequencies == f);
    
    [a, b] = makeFIR(f, 2, fs);
    as(idx,:) = a;
    bs(idx,:) = b;
end

save(['FIR_filters_' num2str(fs) 'Hz'], 'as', 'bs', 'filterFrequencies');