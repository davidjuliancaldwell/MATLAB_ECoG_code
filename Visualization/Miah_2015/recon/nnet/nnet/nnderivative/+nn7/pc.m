function Pc = pc(net,X,Xi,Q,TS,hints)
%NNCALC_MATLAB.PC

% Copyright 2012 The MathWorks, Inc.

TSc = TS + net.numInputDelays;
Pc = cell(net.numInputs,TSc);

for i=1:hints.numInputs
  pfcns = hints.inputs(i).process;
  if (TSc > 0)
    pi = [Xi{i,:} X{i,:}];
  else
    pi = zeros(net.inputs{i}.processedSize,0);
  end
  for k = 1:length(pfcns)
    pi = pfcns(k).apply(pi,pfcns(k).settings);
  end
  Pc(i,:) = fast_mat2cell(pi,Q,TSc);
end

function c = fast_mat2cell(m,colSize,cols)
c = cell(1,cols);
colStart = 0;
for j=1:cols
  c{1,j} = m(:,colStart+(1:colSize));
  colStart = colStart + colSize;
end
