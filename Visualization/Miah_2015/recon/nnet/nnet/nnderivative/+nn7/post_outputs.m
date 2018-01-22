function y=post_outputs(fcns,y)
%POSTPROCESSOUTPUT Applies a network's postprocessing settings to output values
%
% Syntax
%   
%   y2 = nnproc.post_outputs(net,y1)
%
% Description
%
%   PROCESSOUTPUT(net,a1) takes a network and output values (either a
%   matrix or a cell array of matrices) and returns those values after
%   applying the network's preprocessing settings.
%
%   If A is a cell array, it may have as many rows as network targets,
%   or as many rows as network layers.

% Copyright 2007-2012 The MathWorks, Inc.

for i=1:size(y,1)
  y(i,:) = nnproc.reverse(fcns.outputs(i).process,y(i,:));
end
