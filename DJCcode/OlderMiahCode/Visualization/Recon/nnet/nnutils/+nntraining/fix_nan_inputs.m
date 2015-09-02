function [out1,out2] = fix_nan_inputs(net,X,Xi,Ai,T,Q,TS)

% Copyright 2010-2012 The MathWorks, Inc.

anyNaN = false;
for i=1:numel(X)
  if any(any(isnan(X{i})))
    anyNaN = true;
    break;
  end
end
for i=1:numel(Xi)
  if any(any(isnan(Xi{i})))
    anyNaN = true;
    break;
  end
end
if ~anyNaN
  for i=1:numel(Ai)
    if any(any(isnan(Ai{i})))
      anyNaN = true;
      break;
    end
  end
end

if (nargout > 1) || anyNaN
  % Preprocess Combined Inputs and Input States
  % TODO - Use Calc Mode
  toolsML = nnMATLAB;
  hintsML = nnMATLAB.netHints(net,toolsML.hints);
  Pc = toolsML.pc(net,X,Xi,Q,TS,hintsML);
end

if anyNaN
  data.Q = Q;
  data.TS = TS;
  data.X = X;
  data.Xi = Xi;
  data.Ai = Ai;
  hints = nn7.netHints(net);
  hints = nn7.dataHints(net,data,hints);
  
  Y = nn7.y(net,data,hints);

  % Ensure that NaN inputs are associated with NaN targets
  for i=1:numel(Y)
    yi = Y{i};
    T{i}(isnan(yi)) = NaN;
  end

  % Set NaN inputs to zero for safe gradient calculations
  for i=1:numel(Pc)
    pci = Pc{i};
    pci(isnan(pci)) = 0;
    Pc{i} = pci;
  end
end

if nargout == 1
  out1 = T;
else
  out1 = Pc;
  out2 = T;
end

