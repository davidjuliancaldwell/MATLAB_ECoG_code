function Pc = pc(net,X,Xi,Q,TS,hints)
%NNCALC_MATLAB.PC

% Copyright 2012 The MathWorks, Inc.

% TSc Processed Inputs
TSc = net.numInputDelays + TS;
Pc = cell(net.numInputs,TSc);

if (TSc == 0)
  return
end

% Preprocess Initial Input States
for i = 1:net.numInputs
  if (TSc > 0) && (Q > 0)
    pi = [Xi{i,:} X{i,:}];
  else
    pi = zeros(net.inputs{i}.size,0);
  end
  for j=1:hints.numInpProc(i)
    if hints.inp(i).procMapminmax(j)
      settings = hints.inp(i).procSet{j};
      pi = bsxfun(@minus,pi,settings.xoffset);
      pi = bsxfun(@times,pi,settings.gain);
      pi = bsxfun(@plus,pi,settings.ymin);
    else
      pi = hints.inp(i).procApply{j}(pi,hints.inp(i).procSet{j});
    end
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
