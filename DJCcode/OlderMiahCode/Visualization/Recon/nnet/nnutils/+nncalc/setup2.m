function [calcLib,calcNet] = setup2(calcMode,calcNet,calcData,calcHints,isParallel)
% Second step of setup for calculation mode, net, data & hints for
% parallel or non-parallel calculations.  Call this function from inside
% a SPMD block for parallel calculations, outside for non-parallel.

% Copyright 2012 The MathWorks, Inc.

% Net and Data, formatting and hints
if calcHints.isActiveWorker
  calcNet = calcMode.formatNet(calcNet,calcHints);
  calcHints = calcMode.dataHints(calcNet,calcData,calcHints);
  calcData = calcMode.formatData(calcData,calcHints);
  calcHints = calcMode.codeHints(calcHints);
else
  calcNet = {};
  calcData = {};
end

% Wrap calcMode in main
calcLib = nnCalcLib(calcMode,calcData,calcHints);
