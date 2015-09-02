function [onsets, depths] = findHGOnsets(X, t, fs)
    Xs = GaussianSmooth(X, 1*fs);
    
    DBG = 0;
    
    if (DBG)
        h = figure;
    end
    
    onsets = zeros(size(X,2),1);
    depths = zeros(size(X,2),1);
    
    for c = 1:size(X, 2)        
        if (DBG)
            plot(t,X(:,c));
            hold on;
            plot(t,Xs(:,c),'r:');
        end
        
        [lowest, lidx] = min(Xs(t>0&t<1,c));
        lidx = lidx + find(t>0,1,'first');
        highest = max(Xs(t>t(lidx)&t<2,c));
             
        depths(c) = highest-lowest;
        
        temp = find(Xs(t>t(lidx)&t<2,c) > (highest+lowest)/2, 1, 'first');
        
        if (isempty(temp))
            onsets(c) = find(t>=1, 1, 'first');
        else
            onsets(c) = temp + lidx;
        end
        
        if (DBG)
            hline([lowest, highest]);
            hline((highest+lowest)/2,'g:');

            vline(t(onsets(c)), 'g:');
            title(num2str(c));
            x = 5;
            hold off;
        end
    end
    
    if (DBG)
        close(h);
    end
end