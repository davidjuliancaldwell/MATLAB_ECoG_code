function [squareDists,dists] = matrixDist(inputMatrix)
% DJC - 3/22/2016 
% This function computes the euclidian distance between points in a matrix
% the first output is the output from squareform, so the distance between
% the i-th and j-th entry in the matrix. The second is the output from the
% pdist function. Probably use the 1st

dists = pdist(inputMatrix,'euclidean');
squareDists = squareform(dists);

end