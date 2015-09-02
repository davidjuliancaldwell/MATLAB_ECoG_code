%Parameters
recordedLength = 10000;
windowSize = 300;
prePostLag = 200;

%memory declarations
if ~exist('x')
    x = rand(recordedLength,1);
    y = rand(recordedLength,1);
end

% x = rand(recordedLength,1);
% y = rand(recordedLength,1);

heightOut = prePostLag*2+1;
widthOut = recordedLength;
out = zeros(heightOut,widthOut);

% divide up data into blocks
GRID_X = recordedLength;
GRID_Y = 1;

% Assume we've got 2 * PPL + 1 threads.  Will that fit into one block?
threadsPerBlock = ceil(heightOut/32)*32;

while threadsPerBlock > 512
    %Nope.  Block the data in halves, and round up to the next power of 32
    GRID_Y = GRID_Y + 1;
    threadsPerBlock = ceil((heightOut/GRID_Y)/32)*32;
end


BLOCK_X = threadsPerBlock;
BLOCK_Y = 1;

dimBlock = [BLOCK_X BLOCK_Y];
dimGrid = [GRID_X, GRID_Y];

leftAlpha = ceil(windowSize/2);
rightAlpha = floor(windowSize/2);

fprintf('\n\n----START----\n'); 
fprintf('Output size: %ix%i\n', heightOut, widthOut);
fprintf('Grid Dims: %ix%i\n', GRID_X, GRID_Y);
fprintf('Block Dims: %ix%i\n', BLOCK_X, BLOCK_Y);
for blockIdx_X = 9801:GRID_X-1
    t = blockIdx_X;
    fprintf('Sample t=%i\n', t);
    
    if t-leftAlpha < 0
        fprintf('  -Invalid window range (negative), skipping\n');
        continue;
    end
    
    yRange = t - leftAlpha:t+rightAlpha;
    fprintf('  -Pulling y(%i:%i) into shared memory\n', min(yRange), max(yRange));
    
    ySM = y(yRange+1); % +1 for matlab <== NEEDS to BE THREADED 
    
    D_IDX = t - prePostLag;
    L_IDX = t + prePostLag;
    
    xRange = D_IDX - leftAlpha:L_IDX + rightAlpha;
    
    fprintf('  -Possible xRange for this sample: %i-%i\n', min(xRange), max(xRange));
    
    %Lb = ceil((2 * prePostLag + 1)/GRID_Y);
    Lb = BLOCK_X;
    
    for blockIdx_Y = 0:GRID_Y-1
        fprintf('  Block (%3i,%3i)\n', blockIdx_X, blockIdx_Y);
        
        Cs = blockIdx_Y * Lb + D_IDX;
        Ce = min((blockIdx_Y+1)*Lb + D_IDX - 1, L_IDX);
        
        fprintf('    -Evaluating x from %i:%i length %i\n', Cs, Ce, length(Cs:Ce));
        
        SM = Cs - leftAlpha:min(Ce + rightAlpha,L_IDX + rightAlpha);
        
        
        fprintf('    -Pulling x(%i:%i) into shared memory xSM for this block, length %i\n', min(SM), max(SM), length(SM));
%         xSM = x(SM); % PULL TO LOCAL MEM
        
        xSM = -ones(length(SM),1) * 1.1;
        
        stride = BLOCK_X;
        lengthSM = length(SM);
        hold off;
        plot(xSM);
        hold on;
        
        % "randomly" arrive and start filling xSM BLOCK_X,
        for threadIdx = randsample(0:BLOCK_X-1, BLOCK_X)           
            % For plotting purposes
            colr = rand(3,1);
            while threadIdx < lengthSM
                globalMemLocation = SM(threadIdx+1);
                if globalMemLocation >= 0
                    xSM(threadIdx+1) = x(SM(threadIdx+1)+1); % + 1 for matlab) 
                    plot(threadIdx+1,xSM(threadIdx+1),'marker','.','linestyle','none','color',colr);
                else
                    % Load a zero
                    xSM(threadIdx+1) = 0; 
                end
                threadIdx = threadIdx + stride;
            end
        end
        
        fprintf('    -Required %i bytes shared memory in total\n', (length(xSM)+length(ySM)) * 4);
        
        %% __synchronizeThreads();
        
        
        outOfRange = 0;
        for threadIdx = 0:BLOCK_X-1

            if(blockIdx_Y*BLOCK_X + threadIdx+1 > heightOut)
                outOfRange = outOfRange + 1;
                continue;
            end
            
            smIndex = threadIdx:threadIdx+windowSize; 
%             outCol = blockIdx_X;
%             outRow = blockIdx_Y * BLOCK_X + threadIdx;

%             if (threadIdx + 19 > BLOCK_X || threadIdx < 2)
                fprintf('    ThreadIDX: %3i - blockIdx: (%3i,%3i)\n', threadIdx, blockIdx_X, blockIdx_Y);
                hold off;
                plot(ySM);
                hold on;
                plot(xSM(smIndex+1),'r');
                axis tight;
%                 pause(0.5);
%             end
            
        end
        if outOfRange > 0
            fprintf('    -Had %i idle threads\n', outOfRange);
        end
    end
end


%%
for threadsPerBlock = 1:512;
    leftoverThreads(threadsPerBlock) = mod(ceil(heightOut / threadsPerBlock) * threadsPerBlock, heightOut);
end

plot(1:512,leftoverThreads);
hold on;

clear leftoverThreads
idx = 1;
for threadsPerBlock = 32:32:512;
    leftoverThreads(idx) = mod(ceil(heightOut / threadsPerBlock) * threadsPerBlock, heightOut);
    idx = idx + 1;
end
plot(32:32:512, leftoverThreads,'r');


