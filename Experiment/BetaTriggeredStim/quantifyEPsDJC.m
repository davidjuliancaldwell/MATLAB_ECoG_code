%% modified by DJC 2-10-2016 in attempt to robustly quantify CCEPs
% consider terminology a la keller
% 10-50 ms is A1, 50-250 A2 

function stats = quantifyEPsDJC(t, eps)
    A1_MIN_SEC = 0.010;
    A1_MAX_SEC = 0.050;
    
    A2_MIN_SEC = 0.030;
    A2_MAX_SEC = 0.045;
    
    DBG = 0;
    
    % TODO, determine if we need to do EP inversion
    
    % precalculate
    A1_range = find(t>=A1_MIN_SEC & t<=A1_MAX_SEC);
    A2_range = find(t>=A2_MIN_SEC & t<=A2_MAX_SEC);
    
    stats = zeros(6, size(eps, 2));
    
    for c = 1:size(eps, 2)
        % N1
        [stats(1,c), temp] = min(eps(A1_range, c));
        stats(2,c) = t(A1_range(temp));
    
        % P1
        [stats(3,c), temp] = max(eps(A2_range, c));
        stats(4,c) = t(A2_range(temp));
        
        if (DBG)
            plot(t, eps(:,c));
            hline(stats(1,c), 'r');
            vline(stats(2,c), 'r');
            hline(stats(3,c), 'g');
            vline(stats(4,c), 'g');        
           
            x = 5;
        end
        
    end
end