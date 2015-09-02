function [calcLib,calcNet] = setup(calcMode,net,data)
% Setup calculation mode, net, data & hints for non-parallel calculations

% Copyright 2012 The MathWorks, Inc.

[calcMode,calcNet,calcData,calcHints] = nncalc.setup1(calcMode,net,data);
[calcLib,calcNet] = nncalc.setup2(calcMode,calcNet,calcData,calcHints);
