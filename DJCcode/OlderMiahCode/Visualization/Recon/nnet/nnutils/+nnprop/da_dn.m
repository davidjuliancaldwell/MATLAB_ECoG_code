function S = da_dn(i,fcn,TS,Q,Ae,numLayerDelays,N,extrazeros,layerSize)
%CALCFDOT Calculate derivatives of transfer functions for use in dynamic gradient functions.
%
%	Synopsis
%
%	  [S] = nnprop.da_dn(i,transferFcn,TS,Q,Ae,numLayerDelays,N,extrazeros,layerSize)
%
%	Warning!!
%
%	  This function may be altered or removed in future
%	  releases of Neural Network Toolbox. We recommend
%	  you do not write code which calls this function.

% Copyright 2005-2012 The MathWorks, Inc.

if extrazeros
  extraTS = numLayerDelays+1;
else
  extraTS = 0;
end

S = zeros(layerSize,layerSize,Q,length(TS)+extraTS);

Aei = Ae{i};  
for ts=TS
  ts1Q = (ts-1)*Q; 
  Nit = N{i,ts};
  Aeit = Aei(:,ts1Q+(1:Q)); 
  AderivN = nn_transfer_fcn.da_dn_full(fcn,Nit,Aeit,fcn.param);
  for qq=1:Q
    S(:,:,qq,ts) = AderivN{qq};
  end
end

