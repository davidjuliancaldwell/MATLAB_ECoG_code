N = 100;
W = 60;

x = randn(121, 1);
Y = randn(121, N);

% len = length(xcorr(x, Y(:,1)));
r1 = zeros(2*W+1, N);
% r2 = r1;

% way one
tic
for e = 1:N
    r1(:, e) = xcorr(x, Y(:, e), W, 'coeff');
end
toc


tic
gx = gpuArray(x);
gY = gpuArray(Y);
r2 = mXcorr(gx, gY, W);
r2 = gather(r2);
toc

