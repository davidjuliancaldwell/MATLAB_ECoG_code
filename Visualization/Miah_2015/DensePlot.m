function DensePlot(Rows,Cols,Labels, skip)

if ~exist('skip')
    skip = [];
end

pause(0.00001);
width = .9 / Cols;
height = .9 / Rows;

childs = get(gcf,'Children');
childs = childs(length(childs):-1:1);

skipped = 0;

row = 1;
col = 0;
plotNum = 0;
for child = childs'
    plotNum = plotNum + 1;
    if plotNum == skip
        col = col + 1;
    end
    col = col + 1;
    if col > Cols
        col = 1;
        row = row + 1;
    end
    set(child, 'pos', [(width + .05 / Cols)*(col-1)+.025 1-(height + .1 / Rows)*(row-1)-height width height])   
    set(child,'Xtick',[]);
    set(child,'Ytick',[]);
end
% 
% for r=1:Rows
%     for c = 1:Cols
%         selected = (r-1)*Cols + c - skipped;
%         if selected == skip
%             skipped = 1;
%             selected = selected - 1;
%         end
%         h=childs(selected);
% %         set(h,'Xtick',[]);
% %         set(h,'Ytick',[]);
%         set(h, 'pos', [(width + .1 / Cols)*(c-1)+.05 1-(height + .1 / Rows)*(r-1)-height width height])   
% %         pause(0.25);
%         if exist('Labels') && length(Labels)~= 0
%             annotation('textbox',[(width + .1 / Cols)*(c-1)+width 1-(height + .1 / Rows)*(r-1)-0.025 .001 .001],...
%                 'String',Labels{selected},'VerticalAlignment','middle','HorizontalAlignment','Center','linestyle','none');
%         end
%     end
% end