function [h, S] = barWithControl(data, colors)

    h = bar3(data);
%     cm = get(gcf,'colormap');  % Use the current colormap.
    cnt = 0;

    for jj = 1:length(h)
        xd = get(h(jj),'xdata');
        yd = get(h(jj),'ydata');
        zd = get(h(jj),'zdata');
        delete(h(jj))    
        idx = [0;find(all(isnan(xd),2))];

        if jj == 1
            S = zeros(length(h)*(length(idx)-1),1);
%             dv = floor(size(cm,1)/length(S));
        end

        for ii = 1:length(idx)-1
            cnt = cnt + 1;
            S(cnt) = surface(xd(idx(ii)+1:idx(ii+1)-1,:),...
                             yd(idx(ii)+1:idx(ii+1)-1,:),...
                             zd(idx(ii)+1:idx(ii+1)-1,:),...
                             'facecolor',colors(cnt,:));
        end
    end

	view(270,0);
    
end
