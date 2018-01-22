function wb = formwb(net,b,iw,lw,hints)
%FORMWB Form bias and weights into single vector.
%
%  <a href="matlab:doc formwb">formwb</a>(NET,B,IW,LW) takes a network NET, bias vectors B, input weights
%  IW and layer weights LW and forms the biases and weights into a single
%  vector.
%
%  Here a feed forward network is trained to fit some data, then its
%  bias and weight values formed into a vector.
%  
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    wb = <a href="matlab:doc formwb">formwb</a>(net,net.b,net.iw,net.lw)
%
%  See also GETWB, SETWB, SEPARATEWB.

% Mark Beale, Created from FORMGX, 5-25-98
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.10.5 $  $Date: 2012/04/30 03:02:40 $

if nargin < 5, hints = nn.wb_indices(net); end

wb = zeros(hints.wbLen,1);
for i=1:net.numLayers
  if hints.bInclude(i)
    wb(hints.bInd{i}) = b{i}(:);
  end
  for j=find(hints.iwInclude(i,:))
    wb(hints.iwInd{i,j}) = iw{i,j}(:);
  end
  for j=find(hints.lwInclude(i,:))
    wb(hints.lwInd{i,j}) = lw{i,j}(:);
  end
end
