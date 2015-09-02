x = ones(600,6000);

%%
tic;

res = zeros(80, 600, 6000);

for c = 1:80
    res(c, :, :) = x;
end

toc

%%
tic;

res = zeros(600, 80, 6000);

for c = 1:80
    res(:, c, :) = x;
end

toc

%%
tic;

res = zeros(600, 6000, 80);

for c = 1:80
    res(:, :, c) = x;
end

toc