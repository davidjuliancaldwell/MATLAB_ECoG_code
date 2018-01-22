function Pc = pc(net,X,Xi,Q,TS,hints)

% Copyright 2012 The MathWorks, Inc.

% Allocate Processed Inputs
Pc = cell(net.numInputs,net.numInputDelays + TS);

% Preprocess Initial Input States
for i = 1:net.numInputs
  if (TSc > 0)
    pi = [Xi{i,:} X{i,:}];
  else
    pi = zeros(net.inputs{i}.processedSize,0);
  end
  for j=1:hints.numInpProc(i)
    pi = hints.inp(i).procApply{j}(pi,hints.inp(i).procSet{j});
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
