function hits = buildRandomHitList(numHits, numTrials)
    cont = true;
    
    while (cont == true)
%         fprintf('try');
        hitVals = randn(numTrials, 1);

        thresh = mean(hitVals);
        step = (max(hitVals)-min(hitVals))/4;

        hits = hitVals > thresh;    
        ct = sum(hits);
        timeout_counter = 0;

        failed = false;
        
        while (ct ~= numHits)

            if (ct > numHits) % thresh too low
                thresh = thresh + step;
            else % thresh too high
                thresh = thresh - step;
            end

            hits = hitVals > thresh;
            ct = sum(hits);

            step = step / 2;

            if (timeout_counter > 10000)
                failed = true;
                break;
            end

            timeout_counter = timeout_counter + 1;
        end
        
        if (~failed)
            cont = false;
        end
    end
end