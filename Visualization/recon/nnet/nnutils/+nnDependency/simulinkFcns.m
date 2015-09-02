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
  %'convwf'
  'dotprod'
  'negdist'
  'normprod'
  %'scalprod'
  %'boxdist'
  'dist'
  %'linkdist'
  %'mandist'
  };

fcns.netInputFcns = {
  'netprod'
  'netsum'
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
  };

fcns.outputProcessFcns = {
  'fixunknowns'
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
