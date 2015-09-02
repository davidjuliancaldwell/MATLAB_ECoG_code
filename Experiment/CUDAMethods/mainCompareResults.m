addpath ../Connectivity/

clearIntermediateResults = 0;

results = {};

% vecLength = 10000;
% windowSize = 300;
% prePostLag = 200;
vecLength = 10000;
windowSize = 300;
prePostLag = 300;
decimationFactor = 50;

vec = [0.1:0.05:vecLength / 20]';
a = sin(vec*.25);
b = cos(vec.*2);

% a = rand(10000,1) .* [0;a];
% b = rand(10000,1) .* [0;b];
% 
% a = randn(10000,1);
% b = randn(10000,1);

a = source(1:vecLength);
b = dest(1:vecLength);

%%


fprintf('\n\n************************\n    Parameters\n\n');
fprintf('  Vector length: %i\n', vecLength);
fprintf('  Window size: %i\n', windowSize);
fprintf('  Pre/Post lag: %i\n', prePostLag);
fprintf('  Decimation factor: %i\n', decimationFactor);


timeSpent = [];
fprintf('\n\nRunning tests\n\n');

fprintf('  Naive\t\t');

    fprintf(' [%2i:1] [RUNNING]',decimationFactor);
    try
        tic;
        nwc = naiveWindowedCov(a,b,windowSize,prePostLag, decimationFactor); 
        timeSpent(end+1) = toc;
        fprintf(' [DONE] - Time %.3f seconds\n', timeSpent(end));
    catch
        timeSpent(end+1) = -1;
        fprintf(' [*FAILED*]\n');
    end



%                 figure; imagesc(nwc);

    if clearIntermediateResults == 1
        clear nwc
    end

fprintf('  Optimized\t');

    fprintf(' [%2i:1] [RUNNING]',decimationFactor);
    try
        tic;
        owc = optimizedWindowedCov(a,b,windowSize,prePostLag, decimationFactor); 
        timeSpent(end+1) = toc;
        fprintf(' [DONE] - Time %.3f seconds\n', timeSpent(end));
    catch
        timeSpent(end+1) = -1;
        fprintf(' [*FAILED*]\n');
    end

%                 figure; imagesc(owc);

    if clearIntermediateResults == 1
        clear owc
    end

fprintf('  Parallel\t');

    fprintf(' [%2i:1] [RUNNING]',decimationFactor);
    try
        tic;
        pwc = parallelizedWindowedCov(a,b,windowSize,prePostLag, decimationFactor); 
        timeSpent(end+1) = toc;
        fprintf(' [DONE] - Time %.3f seconds\n', timeSpent(end));
    catch
        timeSpent(end+1) = -1;
        fprintf(' [*FAILED*]\n');
    end

%                 figure; imagesc(pwc);


    if clearIntermediateResults == 1
        clear pwc
    end

fprintf('  Jacket\t');

    fprintf(' [%2i:1] [RUNNING]',decimationFactor);
    try
        tic;
        jwc = double(jacketWindowedCov(a,b,windowSize,prePostLag, decimationFactor)); 
        timeSpent(end+1) = toc;
        fprintf(' [DONE] - Time %.3f seconds\n', timeSpent(end));
    catch
        timeSpent(end+1) = -1;
        fprintf(' [*FAILED*]\n');
    end

%                 figure; imagesc(jwc);

    if clearIntermediateResults == 1
        clear jwc
    end

fprintf('  CUDA\t\t');

    fprintf(' [%2i:1] [RUNNING]',1);
    try
        tic;
        cwc = CudaMex_v2(single(b'),single(a'),windowSize,prePostLag); 
        timeSpent(end+1) = toc;
        fprintf(' [DONE] - Time %.3f seconds\n', timeSpent(end));
    catch
        timeSpent(end+1) = -1;
        fprintf(' [*FAILED*]\n');
    end

%                 figure; imagesc(cwc);

    if clearIntermediateResults == 1
        clear cwc
    end
%%    
fprintf('  WinCUDA\t');

    fprintf(' [%2i:1] [RUNNING]',1);
    try
        gw = gausswin(windowSize);
        tic;
        gwc = gausswc(single(b'),single(a'),windowSize,prePostLag,single(gw)); 
        timeSpent(end+1) = toc;
        fprintf(' [DONE] - Time %.3f seconds\n', timeSpent(end));
    catch
        timeSpent(end+1) = -1;
        fprintf(' [*FAILED*]\n');
    end

%                 figure; imagesc(cwc);

    if clearIntermediateResults == 1
        clear gwc
    end

    %%
fprintf('\nSpeedup: \t\t  1x ');
for i=2:length(timeSpent);
    fprintf(' % 8.2f', timeSpent(1)/timeSpent(i));
end

fprintf('\nRelative speedup: 1x ');
for i=2:length(timeSpent);
    if i >= length(timeSpent)-1
        factor = decimationFactor;
    else
        factor = 1;
    end
    fprintf(' % 8.2f', factor * timeSpent(1)/timeSpent(i));
end

fprintf('\n');

%%
figure;
offset = 40;

range = [1:20] + offset;
crange = 150 + (range(1).* 50):(range(end).*50);

subplot(1,5,1);
imagesc(nwc(:,range));
subplot(1,5,2);
imagesc(owc(:,range));
subplot(1,5,3);
imagesc(pwc(:,range));
cl = get(gca,'clim');
subplot(1,5,4);
imagesc(jwc(:,range));

subplot(1,5,5);
imagesc(cwc(:,crange));
DensePlot(1,5);

return;

%%
figure; 
offset = 40;

range = [1:20] + offset;
crange = 150 + (range(1).* 50):(range(end).*50);

subplot(1,6,1);
imagesc(nwc(:,range));
subplot(1,6,2);
imagesc(owc(:,range));
subplot(1,6,3);
imagesc(pwc(:,range));
cl = get(gca,'clim');
subplot(1,6,4);
imagesc(jwc(:,range));

subplot(1,6,5);
imagesc(cwc(:,crange));
% set(gca,'clim',cl);
set(gca,'clim',cl);
subplot(1,6,6);
imagesc(gwc(:,crange));
% set(gca,'clim',cl);
set(gca,'clim',cl);

DensePlot(1,6);