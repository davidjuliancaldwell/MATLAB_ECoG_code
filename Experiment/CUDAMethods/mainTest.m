addpath ../Connectivity/
addpath D:\Code\Cuda\CudaMex_v2\x64\Release

if matlabpool('size') == 0
    matlabpool open;
end

fprintf('\n\nLoading all associated modules... ');

decimationFactor = 50;
windowSize = 300;
prePostLag = 200;
vec = [0.1:0.1:10000 / 10]';
a = sin(vec);
b = cos(vec);

fprintf('[NAIVE] ');
f = naiveWindowedCov(a,b,windowSize,prePostLag, decimationFactor); 
fprintf('[OPTIMIZED] ');
f = optimizedWindowedCov(a,b,windowSize,prePostLag, decimationFactor); 
fprintf('[PARALLEL] ');
f = parallelizedWindowedCov(a,b,windowSize,prePostLag, decimationFactor); 
fprintf('[JACKET] ');
jwc = double(jacketWindowedCov(a,b,windowSize,prePostLag, decimationFactor)); 
fprintf('[CUDA] ');
cwc = CudaMex_v2(single(b),single(a),windowSize,prePostLag); 
fprintf('[WINCUDA] ');
gwc = gausswc(single(b),single(a),windowSize,prePostLag,single(gausswin(windowSize))); 
clear f;

fprintf('done.\n');

clearIntermediateResults = 1;

results = {};

for vecLength = 5000:5000:50000
    for windowSize = 100:50:500
        for prePostLag = 100:50:500
            % vecLength = 20000;
            % windowSize = 300;
            % prePostLag = 300;
            decimationFactor = 50;

            vec = [0.1:0.1:vecLength / 10]';
            a = sin(vec);
            b = cos(vec.*2);




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
                    cwc = CudaMex_v2(single(b),single(a),windowSize,prePostLag); 
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
                
            fprintf('  WinCUDA\t');

                fprintf(' [%2i:1] [RUNNING]',1);
                try
                    gw = gausswin(windowSize);
                    tic;
                    gwc = gausswc(single(b),single(a),windowSize,prePostLag,single(gw)); 
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
            
            results = vertcat(results,{vecLength, windowSize, prePostLag, decimationFactor, timeSpent});

        end
    end
end

save finalResults results