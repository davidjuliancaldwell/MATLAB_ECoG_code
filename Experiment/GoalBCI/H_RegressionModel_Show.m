%% define constants
addpath ./functions
Z_Constants;

DO_FORCE = false;
DO_GAUSS = false;
NADDS = 1;

%% This script is going to try to condense the results from the individual regression models down to something
% digestable and meaningful on an average subject basis.

% what are the questions we want to ask?
% is there significant representation of feature X?
% is there a spatial trend to the representation of that feature?
% does the representation of that feature come at a consistent lag across
% subjects?

% For velocity
%  Thresholded Gaussian Plots of t-statistics 
%  Summary plot showing median lag or something similar?

% For error
%  Thresholded Gaussian Plots of t-statistics 
%  Summary plot showing median lag or something similar?

% For interaction
%  Thresholded Gaussian Plots of t-statistics 
%  Summary plot showing median lag or something similar?

% For direction
%  Thresholded Gaussian Plots of t-statistics 

%% collect the data
if (DO_FORCE)
	txts = {'velocity', 'error' 'interaction'};
% 	txts = {'paths', 'velocity', 'error', 'interaction', 'derror'};
%     txts = {'velocity', 'interaction', 'derror'};
%     txts = {'velocity', 'error', 'interaction'};
    
    weights = cell(length(txts) + NADDS, 1);
    locs =    cell(length(txts) + NADDS, 1);
    srcs =    cell(length(txts) + NADDS, 1);
    bas =     cell(length(txts) + NADDS, 1);
    hmats =   cell(length(txts) + NADDS, 1);
    lags =    cell(length(txts) + NADDS, 1);
    
    allbas = [];
    allsrcs = [];
    
    for c = 1:length(SIDS)
        subjid = SIDS{c};
        subcode = SUBCODES{c};

        load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 'cchan', 'hemi', 'montage', 'bad_channels');
        load(fullfile(META_DIR, ['regression ' subjid '.mat']), 'ts', 'ps', 'amaxlag', 'included');

        areas = brodmannAreaForMontage(subjid, montage)';
        
        tlocs = projectToHemisphere(trodeLocsFromMontage(subjid, montage, true), 'r');

        % count the total number of predictors included in all models for
        % this subject
        pthresh = 0.05 / sum(cellfun(@(x) sum(x), included));
        
        for d = 1:(length(txts) + NADDS)
            temp = toCol(cellfun(@(x) x(d),ts));
            tempp = toCol(cellfun(@(x) x(d),ps));
            
            if (c==3)
                temp(63:64) = [];
                tempp(63:64) = [];
            end
            
%             % most conservative, full bonf
%             good = tempp <= 0.05 / length(ps) * length(ps{1});

%             % intermediately conservative, bonf on all considered preds
%             good = tempp <= pthresh;
            
            % bonf on this predictor alone (n chans)
            [~, good] = bonf(tempp, 0.05);

            weights{d} = cat(1, weights{d}, temp(good));
            locs{d} = cat(1, locs{d}, tlocs(good, :));                
            srcs{d} = cat(1, srcs{d}, c*ones(sum(good),1));
            hmats{d} = cat(1, hmats{d}, hmatValueForElectrodes(tlocs(good,:)));
            bas{d} = cat(1, bas{d}, areas(good));
            
            if (d==1)
                allbas = cat(1, allbas, areas);
                allsrcs = cat(1, allsrcs, c*ones(length(good), 1));
            end
            
            if (d <= length(txts))
                lags{d} = cat(1, lags{d}, toCol(amaxlag{d}(good)));
            else
                lags{d} = cat(1, lags{d}, zeros(sum(good),1));
            end
        end               
    end        

    save(fullfile(META_DIR, 'regression_results.mat'), 'weights', 'locs', 'srcs', 'hmats', 'bas', 'txts', 'lags', 'allsrcs', 'allbas');
else
    load(fullfile(META_DIR, 'regression_results.mat'));
end


%% do some plots
for d = 1:(length(txts) + NADDS)
    
    %% do the tstat cortical plots
    figure
    w = weights{d};
%     if (d==1)
%         tr = 10;
%     else 
        tr = 1.96;
%     end

%     drops = abs(w) == 0;
    drops = abs(w) < tr;

    w(drops) = [];
    l = locs{d}(~drops, :);
    s = srcs{d}(~drops);
    
% %     if (DO_GAUSS)
% %         PlotGaussDirect('tail', l, w, 'r', getCLims(w), 'america');
% %     else            
% %         PlotDotsDirect('tail', l, w, 'r', getCLims(w), 10, 'america', s, true);
% %     end
% % 
% %     load('america');
% %     colormap(cm);
% %     colorbarLabel('T-statistic');
% %     set_colormap_threshold(gcf, [-tr tr], getCLims(w), [1 1 1])
% % 
% %     if (d > length(txts))        
% %         if (d-length(txts) == 1)
% %             title('target direction');
% %             SaveFig(OUTPUT_DIR, 'all target dir', 'png', '-r300');
% %             view(270,0);
% %             if (DO_GAUSS)
% %                 camlight
% %             end
% %             SaveFig(OUTPUT_DIR, 'all target dir med', 'png', '-r300');
% %         else
% %             error 'unknown value for d';
% %         end
% %     else
% %         title(txts{d});
% %         SaveFig(OUTPUT_DIR, ['all ' txts{d}], 'png', '-r300');
% %         view(270,0);
% %             if (DO_GAUSS)
% %                 camlight
% %             end
% %         SaveFig(OUTPUT_DIR, ['all ' txts{d} ' med'], 'png', '-r300');
% %     end
% %     
% %     %% do the lag cortical plots plots
% %     if (d <= length(txts))
% %         figure
% %         
% %         g = lags{d}(~drops);
% %         
% %         % hardcoding lag limits
% %         
% %         if (DO_GAUSS)
% %             PlotGaussDirect('tail', l, g, 'r', [-1 1], 'america');
% %         else            
% %             PlotDotsDirect('tail', l, g, 'r', [-1 1], 10, 'america', s, true);
% %         end
% % 
% %         load('america');
% %         colormap(cm);
% %         colorbarLabel('lag (s)');
% % 
% %         title(txts{d});
% %         SaveFig(OUTPUT_DIR, ['all lags' txts{d}], 'png', '-r300');
% %         view(270,0);
% %             if (DO_GAUSS)
% %                 camlight
% %             end
% %         SaveFig(OUTPUT_DIR, ['all lags' txts{d} ' med'], 'png', '-r300');        
% %     end
% %     
% %     
    %% do the bubble plots
    if (d <= length(txts))
        w = weights{d};
        lg = lags{d};
        s = srcs{d};
        
        figure
        wlag = [];
        for si = 1:max(s)
            
            idxs = s==si;
            
            if (any(idxs))
                nt = abs(w(idxs))/max(abs(w(idxs)));

                ax = scatter(jitter(si*ones(sum(idxs), 1), 0.025), lg(idxs), 100*nt, w(idxs), 'fill', 'markeredgecolor', 'k');
%                 ax = scatter(jitter(si*ones(sum(idxs), 1), 0.025), lg(idxs), 100*nt, 'o', 'facecolor', 'r', 'markeredgecolor', 'k');
                hold on;

                % calculate weighted lag
                wlag(si) = sum(nt .* lg(idxs)) / sum(nt);

%                 % calculate the average lag
%                 wlag(si) = mean(lg(idxs));

%                 % calculate the median lag
%                 wlag(si) = median(lg(idxs));
                                
                plot(si + [-0.3 0.3], [wlag(si) wlag(si)], 'k', 'linew', 2);
            else
                wlag(si) = NaN;
            end
        end
            
        load('america');
        colormap(cm)
        colorbarLabel('T-statistic');
        
        set(gca, 'clim', getCLims(w));
        
%         hold on;
%         md = arrayfun(@(x) median(lg(s==x)), unique(s));
%         bar(max(s)+2, mean(md), 'linew', 2, 'edgecolor', 'k', 'facecolor', [.5 .5 .5]);
%         errorbar(max(s)+2, mean(md), sem(md), 'k', 'linew', 2);
        bar(max(s)+2, nanmean(wlag), 'linew', 2, 'edgecolor', 'k', 'facecolor', [.5 .5 .5]);
        errorbar(max(s)+2, nanmean(wlag), nansem(wlag,2), 'k', 'linew', 2);

        
        set(gca, 'xtick', [1:max(s) max(s)+2])
        set(gca, 'xticklabel', cat(1, num2cell(1:max(s))', 'all'));
%         [h,p] = ttest(md);
        [h,p] = ttest(wlag);
        sigstar({{max(s)+2 max(s)+2}}, p);
        
         fprintf('%f, %f, %f\n', nanmean(wlag), nansem(wlag'), p);
        
        xlabel('subject');
        ylabel('lag (s) [neg. means brain leads behavior]');
        title(txts{d});
        
        ylim([-1 1]);
        vline(max(s)+1, 'k');
        ylim([-1.1 1.1]);
        SaveFig(OUTPUT_DIR, ['all bar ' txts{d}], 'eps', '-r300');        
        SaveFig(OUTPUT_DIR, ['all bar ' txts{d}], 'png', '-r300');        
    end    

    %% do the simple -talk plots - number of significant electrodes by subject
    figure
    foo = arrayfun(@(e) sum(srcs{d}==e), 1:9);
    bar(foo);
   
    title(txts{d}, 'fontsize', 18);
    xlabel('subject', 'fontsize', 18);
    
    ylim([0 max(arrayfun(@(d) max(histc(srcs{d},1:9)), 1:(length(txts)+NADDS))) * 1.1]);
    set(get(gca, 'children'),'facecolor', [.5 .5 .5]);
    ylabel('# significant relationships', 'fontsize', 18);
    set(gca,'fontsize', 14);
    
    SaveFig(OUTPUT_DIR, ['talk-' txts{d} '-1'], 'png', '-r600');
    
    
    %% do the simple-talk plots weighted mean lag
    figure
    bar(wlag);

    title(txts{d}, 'fontsize', 18);
    xlabel('subject', 'fontsize', 18);

    
    set(get(gca, 'children'),'facecolor', [.5 .5 .5]);
    ylabel('weighted mean lag (s)', 'fontsize', 18);
    set(gca,'fontsize', 14);
    
    hold on;
    ax = bar(11, nanmean(wlag));
    set(ax, 'facecolor', [1 0 0]);
    ax = errorbar(11, nanmean(wlag), nansem(wlag'), 'k');    
    set(ax, 'linestyle', 'none');
    
    ylim([-.9 .9]);
    vline(10,'k');
    ylim([-1 1]);
    
    SaveFig(OUTPUT_DIR, ['talk-' txts{d} '-2'], 'png', '-r600');
    
    %% do the BA plots
    b = bas{d}(~drops);
    
    bads = isnan(b);
  
    uniqueAreas = unique(allbas(~isnan(allbas)));
%     uniqueAreas = unique(b(~bads));
    
    act = zeros(length(SIDS), length(uniqueAreas));
    covg = zeros(length(SIDS), length(uniqueAreas));
    
    for areai = 1:length(uniqueAreas)
        area = uniqueAreas(areai);
        
        for sidx = 1:length(SIDS)
            act(sidx, areai) = any(b(s==sidx)==area);
            covg(sidx, areai) = any(allbas(allsrcs==sidx)==area);
        end
    end
    
    figure
    ax = bar([sum(act); sum(covg)]');
    set(ax(1),'facecolor',[1 0 0]);
    set(ax(2),'facecolor',[0 0 1]);
    
    pins = find(sum(act)./sum(covg) >= .5 & sum(covg) >= 2);
    hold on;
    plot(pins, sum(covg(:,pins))+.5, 'k+', 'linew', 2, 'markersize', 5);
    
    ylabel('N Subjects', 'fontsize', 24);
    xlabel('Brodmann Area', 'fontsize', 24);
    set(gca, 'xtick', 1:length(uniqueAreas));
    set(gca, 'xticklabel', uniqueAreas);
%     set(gca, 'fontsize', 18);
    set(legend('Activity', 'Coverage', 'location', 'southoutside'), 'fontsize', 18);
    set(gca, 'ylim', [0 9]);
    set(gca, 'xlim', [0 length(uniqueAreas)+1]);
    
    set(gcf,'pos',[624   474   929   504]);
    
    if (d <= length(txts))
        title([upper(txts{d}(1)) txts{d}(2:end)], 'fontsize', 24);
        SaveFig(OUTPUT_DIR, ['all ba ' txts{d}], 'png', '-r300');        
        SaveFig(OUTPUT_DIR, ['all ba ' txts{d}], 'eps', '-r300');        
    else
        title('Target location', 'fontsize', 24);
        SaveFig(OUTPUT_DIR, ['all ba tgt'], 'png', '-r300');        
        SaveFig(OUTPUT_DIR, ['all ba tgt'], 'eps', '-r300');        
    end
    

end

% figure
% PlotDotsDirect('tail', locs{1}, bas{1}, 'r', [0 max(bas{1})], 10, 'recon_colormap', bas{1}, true);
