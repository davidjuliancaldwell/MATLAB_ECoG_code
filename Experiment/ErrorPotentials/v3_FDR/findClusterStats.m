function [vals, clusters] = findClusterStats(h, ts)
    % find clusters
    [L, N] = bwlabel(h, 8);

%     [clusters, ~, N] = bwboundaries(h, 'noholes');
%     
% %     [clusters, ~, ~, A] = bwboundaries(h);
% % 
% %     % count the parent boundaries and drop all children
% %     N = 0;
% %     c = 1;
% %     while c <= length(clusters)
% %         if (~sum(A(c,:)))
% %             N = N + 1;
% %             c = c + 1;
% %         else
% %             clusters(c) = [];
% %         end
% %     end
%     
%     vals = zeros(N, 1);
    
    % for each cluster 
%     figure;
    
    for c = 1:N
%         imagesc((L==c)');
%         pause;
        vals(c) = sum(sum(ts(L==c)));
%         disp (vals(c))
    end
    
    if (nargout == 2)
        clusters = cell(N, 1);
        for c = 1:N
            [row, col] = find(L==c);
            clusters{c} = [row col];
        end
    end
end