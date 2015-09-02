function Pd = pd(net,Pc,Q,TS,hints)
%NNCALC_MATLAB.PD

% Copyright 2012 The MathWorks, Inc.

% Allocate Processed Inputs
Pd = cell(net.numLayers,net.numInputs,TS);
NID = net.numInputDelays;

% Delay and Concatenate Inputs
empty = {zeros(0,Q)};
for i=1:net.numLayers
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      for ts=1:TS
        p_ts = (NID+ts)-net.inputWeights{i,j}.delays;
        if hints.iwUnitDelay(i,j)
          Pd{i,j,ts} = Pc{j,p_ts};
        else
          Pd{i,j,ts} = cat(1,Pc{j,p_ts});
        end
      end
    else
      Pd(i,j,:) = empty;
    end
  end
end
