function fcns = netFcns

% Copyright 2012 The MathWorks, Inc.

fcns.inputProcessFcns = {
  'fixunknowns'
  'mapminmax'
  'mapstd'
  'processpca'
  'removeconstantrows'
  'removerows'
  };

fcns.weightFcns = {
  'convwf'
  'dotprod'
  'negdist'
  'normprod'
  'scalprod'
  'dist'
  'boxdist'
  'linkdist'
  'mandist'
  'nntest.dotprod2'
  'nntest.dotprod3'
  'nntest.gamprod'
  'nntest.vgamprod'
  };

fcns.netInputFcns = {
  'netprod'
  'netsum'
  'nntest.netsum2'
  };

fcns.transferFcns = {
  'compet'
  'hardlim'
  'hardlims'
  'logsig'
  'netinv'
  'poslin'
  'purelin'
  'radbas'
  'radbasn'
  'satlin'
  'satlins'
  'softmax'
  'tansig'
  'tribas'
  'elliotsig'
  'elliot2sig'
  'nntest.tansig2'
  };

fcns.outputProcessFcns = {
  'lvqoutputs'
  'mapminmax'
  'mapstd'
  'processpca'
  'removeconstantrows'
  'removerows'
  };

fcns.performFcns = {
  'mae'
  'mse'
  'sae'
  'sse'
  };
