function [r2, t_ends] = corrWindows(mepochs, ups, t, t_0, t_step, t_win, bad_channels)

    t_ends = (t_0+t_win):t_step:max(t);

    r2 = zeros(size(mepochs, 2), length(t_ends));

    for chan_idx = 1:size(mepochs, 2)
        if (~ismember(chan_idx, bad_channels))
            for t_idx = 1:length(t_ends)
                tkeep = t>=(t_ends(t_idx)-t_win) & t <= t_ends(t_idx);
                data = squeeze(mepochs(:,chan_idx, tkeep));
    %             data = squeeze(epochs(5,:,chan_idx, tkeep));
                clusters = kmeans(data, 2);
                r2(chan_idx, t_idx) = corr(clusters, ups).^2;
            end
        end
    end

end