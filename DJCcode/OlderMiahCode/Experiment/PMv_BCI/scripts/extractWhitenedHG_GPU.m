function bb = extractWhitenedHG_GPU(sig, fs, baseline)
% sig is TxChan
% fs is a number
% baselineis of length T, binary for what samples to use as
% normalization

%     FW = [1:3:50 70:3:110 130:3:200];
    FW = [70:2:100 140:2:150];

    [~,~,call] = time_frequency_wavelet(sig, FW, fs, 1, 1, 'mGPU');

%     call = log(permute(abs(call), [2 1 3]));
    call = abs(call);
    
    bb = zeros(size(sig));
%     considerable = false(size(sig, 1), 1);
%     considerable(round(.2*length(considerable)):round(.8*length(considerable))) = 1;
    
    baseline(1:(round(.1*length(baseline)))) = 0;
    baseline(round(0.9*length(baseline)):end) = 0;
    
    for c= 1:size(sig, 2)
        calln = normalize_plv(call(:,:,c)', call(baseline, :, c)');
        bb(:,c) = mean(calln, 1);
    end
end