
tic;
[~,~,call] = time_frequency_wavelet(sig(:,1:2), FW, fs, 1, 1, 'CPUtest');
toc;
tic;
[~,~,call] = time_frequency_wavelet(sig(:,1:2), FW, fs, 1, 1, 'mGPU');
toc;