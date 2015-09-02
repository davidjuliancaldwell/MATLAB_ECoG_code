function plotCoverage
    % plots the approximate grid coverage for all subjects
    fig_setup;
%     subjids = {'26cb98', '38e116', '4568f4', '30052b', 'fc9643', 'mg', '04b3d5'};

    figure;
%     PlotCortex('tail', 'r');
    
    colors = 'rgbcmky';
    
    for subjidx = 1:length(subjids)
        addCoverage(subjids{subjidx}, colors(subjidx), subjidx);
    end
end

function addCoverage(subjid, color, idx)
    load(['d:\research\code\output\1DBCI\cache\fig_overall.' subjid '.mat'])
    locs = trodeLocsFromMontage(subjid, Montage, true);

    if (strcmp(subjid, 'fc9643'))
        Montage.Montage = Montage.Montage(1);
        Montage.MontageTrodes = Montage.MontageTrodes(1:64,:);
        Montage.MontageTokenized = Montage.MontageTokenized(1:1);
        
        
        % drop the depth electrodes manually
    end
    
    aplocs = locs;
    aplocs(:,1) = abs(aplocs(:,1));
    
    if (sum(locs(:,1)-aplocs(:,1)) ~= 0)
        lt = ':';
    else
        lt = ':';
    end
    
    sums = cumsum(Montage.Montage);
    
    for elementcounter = 1%1:length(Montage.Montage)
        if (elementcounter == 1)
            start = 1;
        else
            start = sums(elementcounter-1)+1;
        end
        
        stop = sums(elementcounter);
        
        if (start < size(aplocs,1))
            elementlocs = aplocs(start:min(stop, size(aplocs,1)), :);
        
            l = size(elementlocs, 1);
            if (l > 8 && mod(l, 8) == 0)
                for c = 1%:4
                    switch (c)
                        case 1
                            t = 1:8;
                        case 2
                            t = (l-7):l;
                        case 3
                            t = 1:8:l;
                        case 4
                            t = 8:8:l;
                    end

                    line (elementlocs(t,1), elementlocs(t,2), elementlocs(t,3), 'Linewidth', 3, 'Color', color, 'LineStyle', lt);
                end
            elseif (l <= 8)
                e = size(elementlocs, 1);
                line (elementlocs([1:e], 1), elementlocs([1:e], 2), elementlocs([1:e], 3), 'Linewidth', 3, 'Color', color, 'LineStyle', lt);
%                 warning('strips not yet implemented');
            else
                warning('unknown grid type');
            end    
        end
    end

    
end