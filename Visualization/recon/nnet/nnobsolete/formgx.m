function gX = formgx(net,gB,gIW,gLW)
%FORMGX Form bias and weights into single vector.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    gX = formgx(net,gB,gIW,gLW)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of Neural Network Toolbox. We recommend
%    you do not write code which calls this function.
%
%  See also GETX, SETX.

% Mark Beale, 11-31-97
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.8.3 $


hints = nn7.netHints(net);

% Shortcuts
inputLearn = hints.inputLearn;
layerLearn = hints.layerLearn;
biasLearn = hints.biasLearn;
inputWeightInd = hints.inputWeightInd;
layerWeightInd = hints.layerWeightInd;
biasInd = hints.biasInd;

gX = zeros(hints.xLen,1);
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
