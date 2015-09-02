function handle = makeConnectivityPlot(interest, allhs, subjid, class)
step = 2*pi/length(interest);
angles = 0:step:(2*pi-step);

locs = [cos(angles);sin(angles)];

handle = figure;
gplot(allhs, locs', 'b-o');
ls = get(gca, 'Children');
set(ls, 'MarkerSize', 40);
set(ls, 'MarkerFaceColor', [1 1 1]);
set(gca, 'xlim', [-1 1]);
set(gca, 'ylim', [-1 1]);

axis off;
axis equal;
cc = getControlChannel(subjid);

for c = 1:length(locs)
    if (cc == interest(c))
        color = [1 0 0];
    else
        color = [0 0 1];
    end
        
    text(locs(1,c),locs(2,c), [num2str(interest(c)) '\newline' class{c}], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', color);
end

mtit(subjid, 'xoff', 0, 'yoff', .025);