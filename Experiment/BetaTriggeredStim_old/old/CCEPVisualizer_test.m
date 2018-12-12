t = -.1:0.001:.4;
viz = CCEPVisualizer(16, t, t > .1 & t < .3);

%%
for c = 1:10
    viz.update(randn(16, 1000));
    pause(.25);
end

%%
viz.reset();