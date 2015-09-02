%% do plots

%does line plots for RSAs and points out significant channels from JDW,
%moved to function by JDO 8/2013

function legendEntries = linePlots (numChans, HGRSAs, HGSigs, aggregate, BetaRSAs,BetaSigs, activities, filename, par, HGSigsp, BetaSigsp) 
legendEntries = {};

filename = filenameForString(filename);

% first make a combined line plots for all rsas
colors = 'rgbcmyk';
chans = 1:numChans;

%plotting activity for HG and Beta
if (aggregate == true)
    
    %HG figure
    figure
    plot(chans, HGRSAs);
    hold on;
    plot(chans(HGSigs), HGRSAs(HGSigs), '*');
    labels = cellstr(num2str(HGSigsp(HGSigs)'));
    text (chans(HGSigs),HGRSAs(HGSigs),labels);
    clear ('labels')
    
    xlabel('channel number');
    ylabel('R^2');
    title(strcat('Aggregated HG Response...', filename));
    legend('aggregate activity');

    % Beta
    figure;
    plot(chans, BetaRSAs);
    hold on;
    plot(chans(BetaSigs), BetaRSAs(BetaSigs), '*');
    labels = cellstr(num2str(BetaSigsp(BetaSigs)'));
    text (chans(BetaSigs),BetaRSAs(BetaSigs),labels);
    clear ('labels')
    
    xlabel('channel number');
    ylabel('R^2');
    title(strcat('Aggregated Beta Response...', filename));
    legend('aggregate activity');

else %plots as above, only if stimulus codes are not aggregated. 
    legendEntries = {};
    
    % HG figure
    figure;
    for activityIdx = 1:length(activities)
        h(activityIdx) = plot(chans, HGRSAs(activityIdx,:), colors(activityIdx));
        hold on;
        plot(chans(HGSigs(activityIdx,:)), HGRSAs(activityIdx, HGSigs(activityIdx,:)), [colors(activityIdx) '*']);
        for x = 1:length(chans);
            if HGSigs(activityIdx, x);
                %text (x,HGRSAs(activityIdx, x), strcat('p = ', num2str(HGSigsp(activityIdx, x))));
            end
        end
        
        activity = activities(activityIdx);
        if (activity == 0)
            legendEntries{end+1} = 'null';
        else
            try legendEntries{end+1} = par.Stimuli.Value{1, activity}; %try and catch added since data glove epochs aren't labeled as an activity on par.Stimuli.Value
            catch fprintf('no value for par.Stimuli.Value- may be using data glove epochs...')
            end
        end
    end    
    xlabel('channel number');
    ylabel('R^2');
    title(strcat('HG Response...', filename));    
    legend(h, legendEntries);
    
    % Beta figure
    clear h;
    
    figure;
    for activityIdx = 1:length(activities)
        h(activityIdx) = plot(chans, BetaRSAs(activityIdx,:), colors(activityIdx));
        hold on;
        plot(chans(BetaSigs(activityIdx,:)), BetaRSAs(activityIdx, BetaSigs(activityIdx,:)), [colors(activityIdx) '*']);
        for x = 1:length(chans);
            if BetaSigs(activityIdx, x);
                %text (x,BetaRSAs(activityIdx, x), strcat('p =', num2str(BetaSigsp(activityIdx, x))));
            end
        end
        
        activity = activities(activityIdx);
    end        
    xlabel('channel number');
    ylabel('R^2');
    title(strcat('Beta Response...', filename));    
    legend(h, legendEntries);
end
