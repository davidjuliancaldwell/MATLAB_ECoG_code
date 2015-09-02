

function keepAxesPlotted = EventAverage_plot_cb(...
    AxesHandle, montageElectrodeNum, plotNum, loadedData, isBadChannel, arguments )

    result = loadedData.variables.rs;

    if (~isBadChannel)
        % get rid of the rest epochs
        idxs = result.epochs(:,6) ~= 0;
        
        result.epochs = result.epochs(idxs, :);
        chanData = result.zscores (idxs, montageElectrodeNum);
        
        upIdxs = result.epochs(:,6) == 2;
        downIdxs = result.epochs(:,6) == 1;
        
%         plot(find(upIdxs),   chanData(upIdxs),   'r*'); hold on;
%         plot(find(downIdxs), chanData(downIdxs), 'b*');
        
        sFactor = 10;
        
        plot(find(upIdxs),   smooth(chanData(upIdxs),   sFactor), 'r'); hold on;
        plot(find(downIdxs), smooth(chanData(downIdxs), sFactor), 'b');
        
        plot( 3*ones(size(chanData)), 'k:');
        plot(  zeros(size(chanData)), 'k' );
        plot(find(result.epochs(:,8) ~= 0), zeros(size(find(result.epochs(:,8) ~= 0))), 'g');
        plot(-3*ones(size(chanData)), 'k:');
    end
    
    keepAxesPlotted = false;
end

% function showResults(ds, rs)
%     showResult(ds, rs.aggregate);
% end
% 
% function showResult(ds, result)
%     figure;
%     
%     numTrodes = size(result.epochs, 2);
%     dim = ceil(sqrt(numTrodes));
%     
%     t = (1:size(result.epochs,1)) / result.fs;
% 
%     upPasses = result.targets == 1 & result.results == 1;
%     upFailures = result.targets == 1 & result.results == 2;
%     downPasses = result.targets == 2 & result.results == 2;
%     downFailures = result.targets == 2 & result.results == 1;
%     
%     for trode = 1:numTrodes
%         if (result.trodeStatus(trode) == 1)
%             subplot(dim,dim,trode);
%             
%             
%             % up passes
%             upPassMean = mean(squeeze(result.epochs(:,trode,upPasses)),2);
%             if (~isempty(upPassMean))
%                 plot(t, upPassMean, 'y');
%             else
%                 fprintf('plotting empty');
%                 plot(0,0);
%             end
%             
%             hold on;
% 
%             % up failures
%             upFailureMean = mean(squeeze(result.epochs(:,trode,upFailures)),2);
%             if (~isempty(upFailureMean))
%                 plot(t, upFailureMean, 'b');
%             else
%                 fprintf('plotting empty');
%                 plot(0,0);
%             end
%             
%             % down passes
%             downPassMean = mean(squeeze(result.epochs(:,trode,downPasses)),2);
%             if (~isempty(downPassMean))
%                 plot(t, downPassMean, 'r');
%             else
%                 fprintf('plotting empty');
%                 plot(0,0);
%             end
%             
%             % down failures
%             downFailureMean = mean(squeeze(result.epochs(:,trode,downFailures)),2);
%             if (~isempty(downFailureMean))
%                 plot(t, downFailureMean, 'g');
%             else
%                 fprintf('plotting empty');
%                 plot(0,0);
%             end
%             
%             axis tight;
%             highlight(gca, [result.restStart result.restEnd], [], [0.9 0.9 0]);
%             highlight(gca, [result.fbStart result.fbEnd], [], [0 0.9 0]);
%             title(result.trodeLabels{trode});
% 
%             xlabel('trial time (s)');
%             ylabel('HG hilbert amp');
%         end
%     end
% 
%     legend({['up success (N = ' num2str(sum(upPasses)) ')'], ...
%             ['up failure (N = ' num2str(sum(upFailures)) ')'], ...
%             ['down success (N = ' num2str(sum(downPasses)) ')'], ...
%             ['down failure (N = ' num2str(sum(downFailures)) ')']}, ...            
%             'Location', 'EastOutside');
% 
% %     mtit(strrep(file,'_', '\_'), 'xoff', 0, 'yoff', 0.05);
%     maximize(gcf);
%     
% end