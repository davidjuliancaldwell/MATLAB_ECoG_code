Z_Constants;


%% 
overall = zeros(length(SIDS), 2);
trends = cell(length(SIDS), 1);

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    fprintf('%s\n',sid);
    load(fullfile(META_DIR, [sid '_epochs']), 'paths', 'ress', 'tgts', 't', 'src_files', '*Dur');
    
    targetCounts = extractTargetCountFromFilename(src_files);

    %  Determine: overall performance trends
    for targetCount = unique(targetCounts)
        idxs = targetCounts == targetCount;
        hrTemp = mean(tgts(idxs) == ress(idxs));
        fprintf('  %d targets = %0.2f%% |', targetCount, hrTemp);
        hrByTypeTemp = [];
        for d = 1:targetCount
            hrByTypeTemp(d) = mean(tgts(idxs' & tgts==d) == ress(idxs' & tgts==d));
        end
        overall(sIdx, :) = hrByTypeTemp;
        
        fprintf(' %0.2f%%', hrByTypeTemp);
        fprintf('\n');
        
        hitrate{targetCount} = hrTemp;
        hitrateByType{targetCount} = hrByTypeTemp;
    end
    
    % changes in performance per run
    [~, b] = unique(src_files);
    filelist = src_files(sort(b));
    
    isMot = zeros(size(filelist));
    hrByRunTemp = zeros(size(filelist));
            
    
    for fileIdx = 1:length(filelist)
        isMot(fileIdx) = ~isempty(strfind(filelist{fileIdx}, 'mot'));
        
        testResult = zeros(size(src_files));
        for allFileIdx = 1:length(src_files)
            testResult(allFileIdx) = strcmp(src_files{allFileIdx}, filelist{fileIdx});
        end
        
        hrByRunTemp(fileIdx) = mean(tgts(testResult==1) == ress(testResult==1));
    end
    
    
    figure
    legendOff(plot(hrByRunTemp));
    hold on;
    plot(find(isMot==1), hrByRunTemp(isMot==1), 'o');
    plot(find(isMot==0), hrByRunTemp(isMot==0), '*');
    
    if (~isempty(find(isMot==1)))
        if (~isempty(find(isMot==0)))
            legend('overt', 'imagined');
        else
            legend('overt');
        end
    else
        legend('imagined');
    end
    xlabel('Run');
    ylabel('Fraction of targets hit');
    title(['Performance - ' sid]);
    
    SaveFig(OUTPUT_DIR, [sid '-behav-trend'], 'eps', '-r600');            
    
    % make success probability maps
    if (~isempty(paths))
        ypaths = squeeze(paths(2,:,t>0&t<=fbDur));
%         ypaths(:,1) = ypaths(:,2);
%         ypaths = ypaths(:, 1:20:end);
        finalDistance = zeros(size(targetCounts));
        
        for targetCount = unique(targetCounts)
            idxs = targetCounts == targetCount;
            [outcomeMap{targetCount}, successProbabilities{targetCount}, finalDistance(idxs), handle] = buildOutcomeMap(ypaths(idxs, :), tgts(idxs), ress(idxs), t(t>0&t<=fbDur));
            SaveFig(OUTPUT_DIR, [sid '-behav-prob'], 'eps', '-r600');            
        end
    end
    
%     figure
%     hist(finalDistance(finalDistance ~= 0));
    
    save(fullfile(META_DIR, [sid '_behavior']), 'outcomeMap', 'finalDistance', 'hitrate', 'hitrateByType', 'successProbabilities');
end

%%
figure
h = prettybar(overall(:), [zeros(size(overall, 1), 1); ones(size(overall, 2), 1)]);
p = ranksum(overall(:, 1), overall(:, 2));

ylim([0.5 1])
sigstar({{0.85 1.15}}, p);

set(gca, 'xtick', [0.85 1.15]);
set(gca, 'xticklabel', {'Up', 'Down'});

ylabel('Fraction of targets hit');
xlabel('Direction');
title('Performance by trial type');

SaveFig(OUTPUT_DIR, 'behav-overall', 'eps', '-r600');