function OverlayEpochs(epochs, valid, offsetBegin, offsetEnd)

if nargin < 4
    offsetBegin = 0;
    offsetEnd = 0;
end
if nargin < 2
    valid = [];
end


hold on
ylim = get(gca,'ylim');

colors = [];
handles = [];

for epoch=epochs'
	if epoch(3) == 0
        continue
    end
    epoch(1) = epoch(1) + offsetBegin;
    epoch(2) = epoch(2) - offsetEnd;
	
	if isempty(colors) || isempty(find(colors(:,1) == epoch(3),1))
		colors(end+1,1) = epoch(3);
		colors(end,2:4) = 0.8 + 0.2*rand(3,1);
		a = patch([epoch(1),epoch(1),epoch(2),epoch(2)], [ylim(1),ylim(2),ylim(2),ylim(1)],colors(find(colors(:,1)==epoch(3),1),2:4));
		handles = [handles a];
	else
	    a = patch([epoch(1),epoch(1),epoch(2),epoch(2)], [ylim(1),ylim(2),ylim(2),ylim(1)],colors(find(colors(:,1)==epoch(3),1),2:4));
	end

	set(a,'EdgeAlpha',[0]);
%     b = patch([epoch(1)+option_EpochLag,epoch(1)+option_EpochLag,epoch(2)+option_EpochLag,epoch(2)+option_EpochLag], [ylim(1),ylim(2),ylim(2),ylim(1)],color2);
%     set(b,'EdgeAlpha',[0]);
end

legend(handles, 'Tongue', 'Hand');
heightOfBad = (ylim(2) - ylim(1)) / 30;
if ~isempty(valid)
    vInd = 0;
    for epoch=epochs'
        vInd = vInd + 1;
        if epoch(3) == 0
            continue
        end

        if valid(vInd) == 0
            patch([epoch(1),epoch(1),epoch(2),epoch(2)], [-heightOfBad,0,0,-heightOfBad],[1 0 0]);
        end
    %     b = patch([epoch(1)+option_EpochLag,epoch(1)+option_EpochLag,epoch(2)+option_EpochLag,epoch(2)+option_EpochLag], [ylim(1),ylim(2),ylim(2),ylim(1)],color2);
    %     set(b,'EdgeAlpha',[0]);
    end
end
set(gca,'ylim', [-heightOfBad ylim(2)]);
hold off