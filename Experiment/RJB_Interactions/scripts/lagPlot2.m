function lagPlot2(all, allm, early, earlym, late, latem, t, lags)
    figure    
    
    cm = colormap('gray');
    cm = cm(end:-1:1,:);
%     colormap(cm);
    
    clim = [0 max(all(:))];
    
    for sub = {{1,all, allm, 'all'}}
        n = sub{1}{1};
        data = sub{1}{2};
        mask = double(sub{1}{3});
        ttl = sub{1}{4};
                                
%         mask(mask==0) = 1;
%         data = mask .* data;
        
        imagesc(t, lags, data);
        
        B = bwboundaries(mask==1);
        for k = 1:length(B)
            hold on;
            boundary = B{k};
            plot(t(boundary(:,2)), lags(boundary(:,1)), 'w', 'LineWidth', 2)
        end        
        
%         if (any(any(mask==1)))
        [weight, tcenter, lcenter] = findBestLag(data, t, lags, [], false);
        vline(tcenter,'k--');
        hline(lcenter,'k--');
%         end
        
        hline(0, 'k');
        colormap(cm);  
        colorbarLabel(colorbar, 'STWC Coefficient');
        ylabel('lag (s)');
        xlabel('time (s)');                
        title(ttl);
        set(gca, 'clim', clim);        
%         colorbar;
    end
    
end
