function bb = extractWhitenedHG(sig, fs, bads)

% sig is TxChan
%     FW = [1:3:50 70:3:110 130:3:200];
    FW = [70:2:110 130:2:150];

    [~,~,call] = time_frequency_wavelet(sig, FW, fs, 1, 1, 'CPUtest');

    call = log(permute(abs(call), [2 1 3]));
    
    bb = zeros(size(sig));
    considerable = false(size(sig, 1), 1);
    considerable(round(.2*length(considerable)):round(.8*length(considerable))) = 1;
    
    for c= 1:size(sig, 2)
        if(~any(c==bads))
            calln = normalize_plv(call(:,:,c), call(:,considerable, c));
            bb(:,c) = mean(calln, 1);
        end
    end

end