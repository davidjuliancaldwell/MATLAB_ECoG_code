function handle = showFeatures2(features, labels)
    handle = figure;
    
    
    [subx, suby] = subplotDims(size(features, 1));

    ulabels = unique(labels);
    labelcounts = arrayfun(@(x) sum(x==labels), ulabels);
    
    data = NaN*zeros(length(ulabels), max(labelcounts));
    
    
    for chan = 1:size(features, 1)
        subplot(subx, suby, chan);
        
        for ulabeli = 1:length(ulabels)
            data(ulabeli, 1:labelcounts(ulabeli)) = features(chan, ulabels(ulabeli)==labels);

    %         hist(data);
        end
        hist(data', 10);
        
    end
    
%     for chan = 1:size(features, 1)
%         subplot(subx, suby, chan);
%         
%         ulabels = unique(labels);
%         leg = cell(size(ulabels));
%         for i = 1:length(ulabels)
%             
%             ax = histfit(features(chan, labels==ulabels(i)));
%             legendOff(ax(1));
%             set(ax(1), 'visible','off');
%             set(ax(2), 'color', colors(i));
%             hold on;
%             
%             leg{i} = num2str(ulabels(i));
%         end
%         
% %         legend(leg);
%     end
end