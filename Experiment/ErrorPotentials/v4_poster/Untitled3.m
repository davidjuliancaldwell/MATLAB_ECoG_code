function projections = projectOnPCs(data, numPCs)

    C = cov(data);
    [V, D] = eig(C);

    [val, is] = sort(abs(diag(D)));

    pcIdxs = is(end:-1:(end-numPCs+1))

    pc1 = V(:,pc1idx) * val(end);
    pc2 = V(:,pc2idx) * val(end-1);
    pc3 = V(:,pc3idx) * val(end-2);

    % pc1 = GaussianSmooth(V(:,pc1idx) * val(end), 250);
    % pc2 = GaussianSmooth(V(:,pc2idx) * val(end-1), 250);
    % pc3 = GaussianSmooth(V(:,pc3idx) * val(end-2), 250);

    subplot(212);
    plot(t, [pc1 pc2 pc3]);

    %%
    projs = data * [pc1 pc2];

    figure;
    plot(projs(tgts==ress, 1), projs(tgts==ress,2), 'r.');
    hold on;
    plot(projs(tgts~=ress, 1), projs(tgts~=ress,2), 'b.');

    %%
    projs = data * [pc1 pc2 pc3];

    figure;
    plot3(projs(tgts==ress, 1), projs(tgts==ress,2), projs(tgts==ress,3), '.', 'Marker', '.', 'Color', 'r');
    hold on;
    plot3(projs(tgts~=ress, 1), projs(tgts~=ress,2), projs(tgts~=ress,3), '.', 'Marker', '.', 'Color', 'b');

    xlabel('pc1');
    ylabel('pc2');
    zlabel('pc3');

    %%
    figure

    for dim  = 1:3
        subplot(3,1,dim);
        ax = histfit(projs(tgts==ress, dim));
        set(ax(1), 'FaceColor', 'r');
        set(ax(2), 'Color', 'k');
        hold on;
        ax = histfit(projs(tgts~=ress, dim));
        set(ax(1), 'FaceColor', 'b');
        set(ax(2), 'Color', 'k');
    end

    %% 
    figure

    feats = mean(data(:, t > 2.5), 2);
    ax = histfit(feats(tgts==ress));
    set(ax(1), 'FaceColor', 'r');
    set(ax(2), 'Color', 'k');
    hold on;
    ax = histfit(feats(tgts~=ress));
    set(ax(1), 'FaceColor', 'b');
    set(ax(2), 'Color', 'k');
end