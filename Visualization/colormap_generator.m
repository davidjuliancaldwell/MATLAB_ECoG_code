%% DJC - 3-14-2017 - generate colormap to use for plotting, similar to the line_colormap.mat file

% miah red

cm = makeColorMap([0 0 0],[1 0 0],[1 0.6 0.6],64);
save('line_red','cm')

% green
cm = makeColorMap([0 0 0],[0 1 0],[0.6 1 0.6],64);
save('line_green','cm')

% blue
cm = makeColorMap([0 0 0],[0 0 1],[0.7 0.7 1],64);
save('line_blue','cm')
