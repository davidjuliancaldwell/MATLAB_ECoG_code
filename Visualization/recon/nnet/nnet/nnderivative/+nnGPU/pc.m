function Pc = pc(net,X,Xi,Q,TS,hints)
%NNCALC_MATLAB.PC

% Copyright 2012 The MathWorks, Inc.

precision = class(gather(X(1)));

NID = net.numInputDelays;
TSc = NID + TS;
QQ = size(X,1);
N = nn.input_sizes(net);
Nt = sum(N);

if (Nt == 0) || (TS == 0)
  Pc = X;
end

% Combined Inputs
if net.numInputDelays == 0
  Xc = X;
else
  offsets = cumsum([0; N(1:(end-1))]);
  Xc = gpuArray(nan(QQ,Nt*TSc,precision));
  for i=1:net.numInputs
    xiFrom = offsets(i)*NID + 1:(Ni*NID);
    xiTo = offsets(i)*TSc + 1:(Ni*NID);
    Xc(:,xiTo) = Xi(:,xiFrom);
    xFrom = offsets(i)*TS + 1:(Ni*TS);
    xTo = offsets(i)*TSc + (Ni*NID)+1:(Ni*TS);
    Xc(:,xTo) = X(:,xFrom);
  end
end

% MAPMINMAX SETTINGS - No other preprocessing else supported
xoffset = nndata(N,1,1,0);
gain = nndata(N,1,1,1);
ymin = nndata(N,1,1,0);
for i = 1:net.numInputs
  processFcns = net.inputs{1}.processFcns;
  for j=1:numel(processFcns)
    fcn = processFcns{j};
    settings = net.inputs{i}.processSettings{j};
    if strcmp(fcn,'mapminmax') && ~settings.no_change
      xoffset{i} = repmat(feval(precision,settings.xoffset)',1,TSc);
      gain{i} = repmat(feval(precision,settings.gain)',1,TSc);
      ymin{i} = repmat(feval(precision,settings.ymin) + zeros(1,net.inputs{i}.size,precision),1,TSc);
    end
  end
end
xoffset = cell2mat(xoffset);
gain = cell2mat(gain);
ymin = cell2mat(ymin);
if all((xoffset==0) & (gain==1) & (ymin==0))
  Pc = Xc;
  return;
end

% Preprocess Combined Inputs
xoffset = gpuArray(xoffset);
gain = gpuArray(gain);
ymin = gpuArray(ymin);
Pc = bsxfun(@plus,bsxfun(@times,bsxfun(@minus,Xc,xoffset),gain),ymin);

