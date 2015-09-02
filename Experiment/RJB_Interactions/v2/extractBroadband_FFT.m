function bb = extractBroadband_FFT(sig, fs, bads)
% sig is TxChan
    WIN_WIDTH_SEC = 1;
    winWidth = round(WIN_WIDTH_SEC*fs);
    STEP_SIZE_SEC = 0.001;
    stepSize = max(round(STEP_SIZE_SEC*fs), 1); % can't be less than 1

    centers = 1:stepSize:size(sig, 1);
    
    bb_down = zeros(length(centers), size(sig,2));
    
    pre = floor((winWidth-1)/2);
    post = ceil((winWidth-1)/2);
    range = -pre:post;
    
    % precompute a few things for speed
    nfft = 2^nextpow2(winWidth);
    L = size(sig, 1);

    h = waitbar(0, 'extracing broadband');
    
    for chan = 1:size(sig, 2)
        waitbar((chan-1) / size(sig, 2), h);
        
        if (~any(chan==bads))
            gchansig = gpuArray(sig(:,chan));
            call_down = gpuArray(zeros(length(centers), nfft));
            gwin = gpuArray(repmat(hann(winWidth), 1));
            gnfft = gpuArray(nfft);

            edgeCenterIs = (centers <= pre | centers >= (L-post));
            insideCenters = centers(~edgeCenterIs);
            
            rc = repmat(insideCenters, length(range), 1);
            rr = repmat(range', 1, length(insideCenters));
            insideSig = gchansig(rc+rr);
            win = repmat(gwin, 1, length(insideCenters));
            wInsideSig = insideSig .* win;
            
            call_down(~edgeCenterIs, :) = fft(wInsideSig, gnfft)';
                        
            for centerIdx = find(edgeCenterIs)
                center = centers(centerIdx);
                cRange = range+centers(centerIdx);

                if (center <= pre) % early edge case
                    cRange(cRange < 1) = [];
                    gtempwin = gpuArray(repmat(hann(length(cRange)), 1));
                    call_down(centerIdx, :) = fft(gchansig(cRange).*gtempwin, gnfft);            
                elseif (center >= L - post) % late edge case
                    cRange(cRange > size(sig, 1)) = [];            
                    gtempwin = gpuArray(repmat(hann(length(cRange)), 1));
                    call_down(centerIdx, :) = fft(gchansig(cRange).*gtempwin, gnfft);
                end        
            end

            if (mod(nfft, 2) == 1)
                hz = fs/2*linspace(0,1,nfft/2+1/2);
                call_down = 2*call_down(:, 1:nfft/2+1/2, :);
            else
                hz = fs/2*linspace(0,1,nfft/2+1);
                call_down = 2*call_down(:, 1:nfft/2+1, :);
            end

            % subselect frequencies that we like
            keephz = hz < 50 | (hz > 70 & hz < 110) | (hz > 130 & hz < 170);

            % now normalize
            call_down = log(abs(call_down(:, keephz)));
            nspectra = call_down ./ repmat(mean(call_down, 1), size(call_down, 1), 1);

            % perform pca on these spectra
            C = cov(nspectra);
            [vectors, values] = eig(C);

            values = diag(values);
            [~, sortindex] = sort(values, 'descend');
            filters = vectors(:, sortindex);

%             % dummy check our filters
%             if (mean(filters(hz(keephz) < 70)) > mean(filters(hz(keephz) > 70, 1))) 
%                 warning('problem in broadband decomp, chan %d', chan); 
%             end

            bb_down(:, chan) = gather(nspectra * filters(:, 1));
        end
    end
    
    close(h);
    
    t_up = 1:size(sig, 1);
    
    bb = interp1(centers, bb_down, t_up, 'spline');    
end