function stats = quantifyEPs(t, eps)
    N1_MIN_SEC = 0.005;
    N1_MAX_SEC = 0.030;
    
    P1_MIN_SEC = 0.030;
    P1_MAX_SEC = 0.045;
    
    N2_MIN_SEC = 0.045;
    N2_MAX_SEC = 0.120;
    
    DBG = 0;
    
    % TODO, determine if we need to do EP inversion
    
    % precalculate
    N1_range = find(t>=N1_MIN_SEC & t<=N1_MAX_SEC);
    P1_range = find(t>=P1_MIN_SEC & t<=P1_MAX_SEC);
    N2_range = find(t>=N2_MIN_SEC & t<=N2_MAX_SEC);
    
    stats = zeros(6, size(eps, 2));
    
    for c = 1:size(eps, 2)
        % N1
        [stats(1,c), temp] = min(eps(N1_range, c));
        stats(2,c) = t(N1_range(temp));
    
        % P1
        [stats(3,c), temp] = max(eps(P1_range, c));
        stats(4,c) = t(P1_range(temp));

        % N2
        [stats(5,c), temp] = min(eps(N2_range, c));
        stats(6,c) = t(N2_range(temp));
        
        if (DBG)
            plot(t, eps(:,c));
            hline(stats(1,c), 'r');
            vline(stats(2,c), 'r');
            hline(stats(3,c), 'g');
            vline(stats(4,c), 'g');        
            hline(stats(5,c), 'b');
            vline(stats(6,c), 'b');
            
            x = 5;
        end
        
    end
end