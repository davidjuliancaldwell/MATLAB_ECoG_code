function [b,iw,lw] = separatewb(net,wb,hints)
%SEPARATEWB Separate biases and weights from a weight/bias vector.
%
%  [B,IW,LW] = <a href="matlab:doc separatewb">separatewb</a>(NET,WB) takes a network NET and a single
%  vector of biases and weights and returns separated biases, input
%  weights and layer weights.
%
%  Here a feed forward network is trained to fit some data, then its
%  bias and weight values formed into a vector.  The single vector
%  is then redivided into the original biases and weights.
%  
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    wb = <a href="matlab:doc formwb">formwb</a>(net,net.b,net.iw,net.lw)
%    [b,iw,lw] = <a href="matlab:doc separatewb">separatewb</a>(net,wb)
%
%  See also formwb, getwb, setwb.

% Copyright 2010-2012 The MathWorks, Inc.

if nargin < 3, hints = nn.wb_indices(net); end

b = net.b;
iw = net.IW;
lw = net.LW;

for i=1:net.numLayers
  if hints.bInclude(i)
    b{i} = reshape(wb(hints.bInd{i}),...
      net.biases{i}.size,1);
  end
  for j=find(hints.iwInclude(i,:))
    iw{i,j} = reshape(wb(hints.iwInd{i,j}),...
      net.inputWeights{i,j}.size);
  end
  for j=find(hints.lwInclude(i,:))
    lw{i,j} = reshape(wb(hints.lwInd{i,j}),...
      net.layerWeights{i,j}.size);
  end
end
