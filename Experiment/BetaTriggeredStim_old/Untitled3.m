figure
cm = colormap('jet');
cm = interp1(1:size(cm,1), cm, linspace(1, size(cm, 1), size(awins, 2)));
for c = 1:size(awins, 2)
plot(awins(:, c), 'color', cm(c, :));
hold on;
end

%%
figure
for c = 1:size(awins, 2)
    plot(fwins(:, c), 'color', colors(label(c)+1, :));
    hold on;
end

%%

% fwins = bandpass(awins, 500, 1000, efs, 4);


%%
figure
prettyline(t, awins, label, colors);
