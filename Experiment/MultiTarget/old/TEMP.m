for cc = interest
    chan = find(interest == cc)

    iepochsSmooth = squeeze(iepochs(chan, :, :));

    for c = 1:size(iepochsSmooth, 1)
        iepochsSmooth(c, :) = GaussianSmooth(iepochsSmooth(c, :), 250);
    end

    midhits = tgts>=2&tgts<=4&tgts==ress;
    midmiss = tgts>=2&tgts<=4&tgts~=ress;

    outhits = (tgts<2|tgts>4)&tgts==ress;
    outmiss = (tgts<2|tgts>4)&tgts~=ress;

    figure;
    plotWSE(t', iepochsSmooth(midhits, :)', 'b', .5, 'b-', 2);
    hold on;
    plotWSE(t', iepochsSmooth(midmiss, :)', 'r', .5, 'r-', 2);
    plotWSE(t', iepochsSmooth(outhits, :)', 'g', .5, 'g-', 2);
    plotWSE(t', iepochsSmooth(outmiss, :)', 'k', .5, 'k-', 2);

    % figure, plot(t', GaussianSmooth(mean(squeeze(iepochs(chan, midhits, :)),1),250));
    % hold on;
    % plot(t', GaussianSmooth(mean(squeeze(iepochs(chan, midmiss, :)),1),250),'r');
    % plot(t', GaussianSmooth(mean(squeeze(iepochs(chan, outhits, :)),1),250),'g');
    % plot(t', GaussianSmooth(mean(squeeze(iepochs(chan, outmiss, :)),1),250),'k');

    legend('midhits','midmiss','outhits','outmiss');
    title(trodeNameFromMontage(cc, Montage))
    axis tight
end