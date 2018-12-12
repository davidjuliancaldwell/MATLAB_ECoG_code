function awins = adjustStims(wins)    
    awins = zeros(size(wins));


%     % normalize the windows to each other using a single sample just after
%     % stimulus
%     awins = wins-repmat(wins(find(t>7e-3,1,'first'),:), [size(wins, 1), 1]);

%     % normalize the windows to each other removing the median value from
%     % the whole window
%     awins = wins-repmat(median(wins), [size(wins, 1), 1]);

    % normalize the windows to each other, detrending from the pre data to
    % the late data    
%     zwins = wins;
%     zwins(140:200,:) = 0;
%     awins = detrend(wins);


%     % determine the average stim amplutude
%     mu = mean(mean(wins(151:164, :)));
%     
%     % normalize for impedance changes    
%     wins = wins ./ repmat(mean(wins(151:164,:), 1), size(wins, 1), 1);    
%     wins = wins * mu;
    
%     % detrend
%     for e = 1:size(wins, 2)        
%         temp = wins(:, e);        
%         x = [1:100 (length(temp)-99):length(temp)];
%         y = temp(x)';        
%         G = polyfit(x,y,1);                
%         temp = temp - polyval(G, 1:length(temp))';        
%         awins(:, e) = temp;
%     end
    
%     awins(130:170,:) = 0;

    foo = bsxfun(@minus, awins, awins(190,:));
end
