function bb = extractBroadband(sig, fs)

% sig is TxChan
    FW = [1:3:50 70:3:110 130:3:200];

    [~,~,call] = time_frequency_wavelet(sig, FW, fs, 1, 1, 'GPU');
    call = abs(call);
    
    calln = normalize_plv(call, call);
    
    for c= 1:size(sig, 2)
        x = 5;
    end
    
    [projections, weights, varfrac] = mpca(tempn');
    bb = projections(:, 1);
%     bb = zeros(size(sig));
end