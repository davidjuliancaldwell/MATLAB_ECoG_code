function x=getx(net)
%GETX Get all network weight and bias values as a single vector.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    X = getx(net)
%
%  Description
%
%    This function gets a networks weight and biases as
%    a vector of values.
%
%    X = GETX(NET)
%      NET - Neural network.
%      X   - Vector of weight and bias values.
%
%  Examples
%
%    Here we create a network with a 2-element input, and one
%    layer of 3 neurons.
%
%      net = newff([0 1 2; -1 1 0],[-1 1 0]);
%
%    We can get its weight and bias values as follows:
%
%      net.iw{1,1}
%      net.b{1}
%
%    We can get these values as a single vector as follows:
%
%      x = getx(net);
%
%  See also SETX.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2012/03/27 18:22:51 $

% TODO - Replace with GETWB, SETWB

% Shortcuts
hints = nn7.netHints(net);
inputLearn = hints.iwInclude;
layerLearn = hints.lwInclude;
biasLearn = hints.bInclude;
inputWeightInd = hints.inputWeightInd;
layerWeightInd = hints.layerWeightInd;
biasInd = hints.biasInd;

x = zeros(hints.xLen,1);
for i=1:net.numLayers
  for j=find(inputLearn(i,:))
    x(inputWeightInd{i,j}) = net.IW{i,j}(:);
  end
  for j=find(layerLearn(i,:))
    x(layerWeightInd{i,j}) = net.LW{i,j}(:);
  end
  if biasLearn(i)
    x(biasInd{i}) = net.b{i};
  end
end
