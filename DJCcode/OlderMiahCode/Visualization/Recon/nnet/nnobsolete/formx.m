function gX = formx(net,gB,gIW,gLW)
%FORMX Form bias and weights into single vector.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    X = formx(net,B,IW,LW)
%
%  Description
%
%    This function takes weight matrices and bias vectors
%    for a network and reshapes them into a single vector.
%
%    X = FORMX(NET,B,IW,LW) takes these arguments,
%      NET - Neural network.
%      B   - Nlx1 cell array of bias vectors.
%      IW  - NlxNi cell array of input weight matrices.
%      LW  - NlxNl cell array of layer weight matrices.
%    and returns,
%      X   - Vector of weight and bias values.
%
%  Examples
%
%    Here we create a network with a 2-element input, and one
%    layer of 3 neurons.
%
%      net = newff([0 1; -1 1],[3]);
%
%    We can get view its weight matrices and bias vectors as follows:
%
%      b = net.b
%      iw = net.iw
%      lw = net.lw
%
%    We can put these values into a single vector as follows:
%
%      x = formx(net,net.b,net.iw,net.lw)
%
%  See also GETX, SETX.

% Mark Beale, Created from FORMGX, 5-25-98
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.8.2 $  $Date: 2012/03/27 18:22:49 $

% Shortcuts
hints = nn.wb_indices(net);
inputLearn = hints.iwInclude;
layerLearn = hints.lwInclude;
biasLearn = hints.bInclude;
inputWeightInd = hints.iwInd;
layerWeightInd = hints.lwInd;
biasInd = hints.bInd;

gX = zeros(hints.wbLen,1);
for i=1:net.numLayers
  for j=find(inputLearn(i,:))
    gX(inputWeightInd{i,j}) = gIW{i,j}(:);
  end
  for j=find(layerLearn(i,:))
    gX(layerWeightInd{i,j}) = gLW{i,j}(:);
  end
  if biasLearn(i)
    gX(biasInd{i}) = gB{i}(:);
  end
end
