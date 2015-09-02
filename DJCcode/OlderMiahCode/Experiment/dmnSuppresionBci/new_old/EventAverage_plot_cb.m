

function keepAxesPlotted = EventAverage_plot_cb(...
    AxesHandle, montageElectrodeNum, plotNum, loadedData, isBadChannel, arguments )

    result = loadedData.variables.rs.aggregate;

    t = (1:size(result.epochs,1)) / result.fs;
    
    upPasses = result.targets == 1 & result.results == 1;
    upFailures = result.targets == 1 & result.results == 2;
    downPasses = result.targets == 2 & result.results == 2;
    downFailures = result.targets == 2 & result.results == 1;

    if (~isBadChannel)
%         plotWSingleTrials(t, squeeze(result.epochs(:,montageElectrodeNum, upPasses)), 'b');
%         hold on;
%         plotWSingleTrials(t, squeeze(result.epochs(:,montageElectrodeNum, upFailures)), 'r');        
%         plotWSE(t, squeeze(result.epochs(:,montageElectrodeNum, upPasses)), 'b', .5, 'b');
%         hold on;
%         plotWSE(t, squeeze(result.epochs(:,montageElectrodeNum, upFailures)), 'r', .5, 'r');
%         plot(t, squeeze(result.epochs(:,montageElectrodeNum, upPasses)), 'b:');
%         hold on;
%         plot(t, squeeze(result.epochs(:,montageElectrodeNum, upFailures)), 'r:');

        if (montageElectrodeNum == 32)
            plot(t, mean(squeeze(result.epochs(:,montageElectrodeNum, upPasses)),2), 'b');
            hold on;
            plot(t, mean(squeeze(result.epochs(:,montageElectrodeNum, upFailures)),2), 'r');
            plot(t, mean(squeeze(result.epochs(:,montageElectrodeNum, downPasses)),2), 'g');
            plot(t, mean(squeeze(result.epochs(:,montageElectrodeNum, downFailures)),2), 'k');

            axis tight;

            ylims = get(gca,'YLim');

            plot([result.restEnd result.restEnd], [ylims(1) ylims(2)], 'k:');
            plot([result.fbStart result.fbStart], [ylims(1) ylims(2)], 'k:');
            plot([result.fbEnd result.fbEnd], [ylims(1) ylims(2)], 'k:');            
        end
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