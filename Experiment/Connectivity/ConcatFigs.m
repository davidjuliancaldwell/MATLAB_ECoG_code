for chan = 17

    a = dir(sprintf('D:\\Research\\output\\fingerflex\\srcChan %03i\\*.fig',chan));

    if isempty(a)
        fprintf('No files for chan %i skipping...\n',chan);
        continue;
    end

    fprintf('Chan %2i ',chan)
    allPlots = [];
    
    plotIdx = 1;
    for file = a'
        
        fprintf('[%s] ',file.name(12:13));
        uiopen(sprintf('D:\\Research\\output\\fingerflex\\srcChan %03i\\%s',chan, file.name),1);
        subAxis = flipud(get(gcf,'children'));

        for stimCode = 1:7
            
            datums = get(subAxis(stimCode),'children');
            for datum = datums'
                if strcmp(get(datum,'type'),'image') == 1;
                    datums = datum;
                    break;
                end
            end
            datums = get(datums,'CData');
            
             if isempty(datums)
                 %It's blank
                continue;
            end
            
            if isempty(allPlots)
               
                allPlots = zeros(size(datums,1),size(datums,2),64,7);
            end
            allPlots(:,:,plotIdx,stimCode) = datums;
        end
        plotIdx = plotIdx + 1;
        close(gcf);
    end
    
    fprintf('done.\n');


    


    fprintf('Saving each plot separately ');
    tempPlots = allPlots;
    for stimCode = 1:7
        fprintf(' [%i]',stimCode);
        allPlots = tempPlots(:,:,:,stimCode);
        eval(sprintf('save ''D:\\\\Research\\\\output\\\\fingerflex\\\\srcChan %03i\\\\sc_%i.mat'' allPlots',chan, stimCode));
        
    end
    fprintf('\n');
    clear tempPlots allPlots
end