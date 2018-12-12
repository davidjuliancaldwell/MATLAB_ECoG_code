%%
temp = eco;

%%
for hit = hits
    temp(hit:hit+250)=0;
end

%%
ftemp = bandpass(temp, 12, 20, 12000, 4);

%%
pre = 120;
post = 1080;

store = zeros(length(-pre:post),  length(hits));

c = 0;
for hit = hits
    c = c + 1;
    win = ftemp((hit-pre):(hit+post)); 
    store(:, c) = win;
end

%%
clf
t = (-pre:post)/12000 * 1e3;
subplot(211);
plot(t, store(:, mmode(bads)==0), 'color', [.5 .5 .5])
hold on;
plot(t, mean(store(:, mmode(bads)==0),2), 'r', 'linew', 2);
subplot(212);
plot(t, store(:, mmode(bads)==1), 'color', [.5 .5 .5])
hold on;
plot(t, mean(store(:, mmode(bads)==1),2), 'r', 'linew', 2);

