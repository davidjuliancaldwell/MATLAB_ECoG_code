
% for sampleLength = 10000:1000:400000

hBIG = [];
vBIG = [];
unusedSamples = [];
samplesToTest =  100000:10:400000;
for sampleLength = samplesToTest;

	verticalBlocksInGrid = 1;
    horizontalBlocksInGrid = ceil(sampleLength / verticalBlocksInGrid); 

	while(horizontalBlocksInGrid > 65535)
		verticalBlocksInGrid = verticalBlocksInGrid + 1;
        horizontalBlocksInGrid = ceil(sampleLength / verticalBlocksInGrid); 
    end
    
    unusedSamples = vertcat(unusedSamples, verticalBlocksInGrid * horizontalBlocksInGrid - sampleLength);
    hBIG = vertcat(hBIG, horizontalBlocksInGrid);
    vBIG = vertcat(vBIG, verticalBlocksInGrid);
end
% end