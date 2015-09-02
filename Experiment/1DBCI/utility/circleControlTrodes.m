function circleControlTrodes(h, subjids, isTail)
% h is axis handle for plot
    if (~exist('h','var'))
        h = gca;
    end
    
    if (~exist('subjids', 'var'))
        subjids = {'26cb98', '38e116', '4568f4', '30052b', 'fc9643', 'mg', '04b3d5'};
    end
    
    if (~exist('isTail', 'var'))
        isTail = true;
    end

    washeld = ishold(h);
    hold(h, 'on');
    
    for c = 1:length(subjids)
        loc = getCtlLoc(subjids{c}, isTail);
        
        if(isTail)
            loc(:,1) = abs(loc(:,1)); % bounce it to the right hemisphere
        end
        plot3(loc(:,1), loc(:,2), loc(:,3), 'bo', 'MarkerSize', 30, 'LineWidth', 2);
    end
    
	if (~washeld)
        hold(h, 'off');
    end
end