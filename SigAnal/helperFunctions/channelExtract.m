function [extractedChan] = channelExtract(inputMatrix,channelInt)
% DJC - 3/22/2016 
% This is a function to extract channel values of interest from a m x m
% matrix, where m is the number of channels. This could be output from PLV,
% etc . Extracted chan will be a 1 x m vector of the points containing all
% other channels and the selected input channel 

matrixTemp = inputMatrix((1:channelInt),channelInt);
matrixTemp = horzcat(matrixTemp',(inputMatrix(channelInt,(channelInt+1:end))));

extractedChan = matrixTemp;

end