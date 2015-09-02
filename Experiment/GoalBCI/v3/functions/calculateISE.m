function ise = calculateISE(cpath, ytarg, dtarg, fs)
    ise = 0;
    
    DBG = 0;
    
    % integrated squared error is calculated as the distance from the
    % nearest target edge.
    
%     % we disregart the first sample block worth of data because it involves
%     % a large jump from the previous cursor position    
%     SAMPLE_BLOCK_SIZE = 40;    
%     cpath = cpath((SAMPLE_BLOCK_SIZE+1):end);
    
    % now determine the target extents
    targExtent = [(ytarg - dtarg/2) (ytarg + dtarg/2)];
    
    distance = abs(bsxfun(@minus, repmat(cpath,1,2), targExtent));
    distance = bsxfun(@min, distance(:,1), distance(:,2));

    distance(cpath >= targExtent(1) & cpath <= targExtent(2)) = 0;
    
    ise = sum(distance) / fs;
    
    if (DBG)
        figure,
        plot(cpath);
        hold on;
        hline(targExtent(1));
        hline(targExtent(2));
        plot(distance, 'g');
        hold off;
        title(num2str(ise));
    end    
end