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
  y(i,:) = reverse_process(fcns.outputs(i).process,y(i,:));
end

function x = reverse_process(fcns,x)

fcns = active_fcns(fcns);
[rows,cols] = size(x);
functionOrder = length(fcns):-1:1;
for i=1:rows
  for j=1:cols
    xij = x{i,j};
    for k = functionOrder
      fcn = fcns(k);
      xij = fcn.reverse(xij,fcn.settings);
    end
    x{i,j} = xij;
  end
end

function [fcns,active] = active_fcns(fcns)

numFcns = length(fcns);
active = false(1,numFcns);
for i=1:numFcns
  active(i) = ~fcns(i).settings.no_change;
end
fcns = fcns(active);
