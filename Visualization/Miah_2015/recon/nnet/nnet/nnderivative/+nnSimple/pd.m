function Pd = pd(net,Pc,Q,TS,hints)
%NNCALC_MATLAB.PD

% Copyright 2012 The MathWorks, Inc.

% Allocate Processed Inputs
Pd = cell(net.numLayers,net.numInputs,TS);

% Delay and Concatenate Inputs
for ts=1:TS
  for i=1:net.numLayers
    for j=1:net.numInputs
      if net.inputConnect(i,j)
        p_ts = (net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
        Pd{i,j,ts} = cat(1,Pc{j,p_ts});
      end
    end
  end
end
