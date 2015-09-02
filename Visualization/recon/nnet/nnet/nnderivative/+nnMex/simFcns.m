function fcns = simFcns

fcns.inputProcessFcns = {
  %'fixunknowns'
  'mapminmax'
  %'mapstd'
  %'processpca'
  %'removeconstantrows'
  %'removerows'
  };

fcns.weightFcns = {
  %'convwf'
  'dotprod'
  %'negdist'
  %'normprod'
  %'scalprod'
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