function DisplayAsMontage(tFig,Montage,percent,MontageStrings)

totRows = sum(ceil(Montage/8));
totCols = max(max(8*(Montage >= 8)),max(mod(Montage,8)));

plotWidth = percent / totCols;
plotHeight = percent / totRows;

childs = get(tFig,'Children');
childs = childs(length(childs):-1:1);

offset = 0;
drawnRows = 0;
for mTrodes = Montage
    
    mRows = ceil(mTrodes / 8);
    mCols = max(8*(mTrodes >= 8),max(mod(mTrodes,8)));
    for r=[1:mRows]
        for c = 1:mCols
            selected = offset + (r-1)*mCols + c;
%             x = [(plotWidth + .1 / totCols)*(c-1) (plotWidth + .1 / totRows)*(c-1)] + [ 0 plotWidth ];
%             y = [1-(plotHeight + .1 / totCols)*(r-1) 1-(plotHeight + .1 / totRows)*(r-1)] + [ 0 plotHeight ];
            
%             patch([x(1) x(1) x(2) x(2)],[y(1) y(2) y(2) y(1)], 'r');
            h=childs(selected);
    %         set(h,'Xtick',[]);
    %         set(h,'Ytick',[]);
            set(h, 'pos', [(plotWidth + (1-percent) / totCols)*(c-1)+((1-percent)*plotWidth/2)...
                1-(plotHeight + (1-percent) / totRows)*(r+drawnRows-1)-plotHeight-((1-percent)*plotHeight/2)...
                plotWidth plotHeight]);
        end
    end
    drawnRows = drawnRows + mRows;
    offset = offset + mTrodes;
end

subsetAHandle = axes('Position',[0 0 1 1],'Visible','off');
set(tFig,'CurrentAxes',subsetAHandle);
set(subsetAHandle,'xlim',[0 1]);
set(subsetAHandle,'ylim',[0 1]);
hold on;

cIdx = 1;
boxOffset = 0.005;
drawnRows = 0;

colors = [
    [1 0 0];
    [0 1 0];
    [0 0 1];
    [.8 .8 .8];
    [1 1 0];
    [1 0.5 0];
    [0 0.5 1];
    [1 0 0.5];
    [1 0.5 0.5];
    [0.5 1 0.5];
    [0.5 0.5 1];
];

    
for mTrodes = Montage
    
    mRows = ceil(mTrodes / 8);
    mCols = max(8*(mTrodes >= 8),max(mod(mTrodes,8)));
    x = [mCols / totCols];
    y = [mRows / totRows];
    
    rectangle('Position',[boxOffset/2 (totRows - drawnRows - mRows)/totRows+boxOffset/2 x-boxOffset y-boxOffset],'linestyle','--', 'linewidth',2,'edgecolor',colors(cIdx,:));
    drawnRows = drawnRows + mRows;
    cIdx = cIdx + 1;
end


