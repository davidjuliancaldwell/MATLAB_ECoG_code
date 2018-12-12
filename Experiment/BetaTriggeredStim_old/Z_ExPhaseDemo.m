clf
t=0:0.001:2*pi;
f = sin(t);
t = t/(2*pi);
plot(t,f,'linew',4);
 hline(0, 'k:')

t1 = find(t>.75,1,'first');
hold on;
 stem(t(t1), f(t1), 'r', 'linew', 4);
axis off