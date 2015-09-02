function data = flattenTime(data)

% Copyright 2012 The MathWorks, Inc.

if (data.TS == 1)
  return
end

% X, Pc or Pd are flattened
% T, and EW are flattened
% EW may be dimension extended for sample or time to be flattened

% Assumption: Xi is empty or Pd already calculated.
% Either way Xi will not be used.

% Assumption: Ai is empty.

% Flatten version of input with is actually used
if ~isempty(data.Pd)
  data.X = {};
  data.Xi = {};
  data.Pc = {};
  data.Pd = nncalc.seq2con3(data.Pd);
elseif ~isempty(data.Pc)
  data.X = {};
  data.Xi = {};
  data.Pc = nnfast.seq2con(data.Pc);
  data.Pd = {};
else
  data.X = seq2con(data.X);
  data.Xi = {};
  data.Pc = {};
  data.Pd = {};
end

if isfield(data,'T')
  data.T = nnfast.seq2con(data.T);
end

if isfield(data,'EW')
  TSew = size(data.EW,2);
  Qew = size(data.EW{1},2);
  Mew = size(data.EW,1);
  if (TSew == 1) && (data.TS ~= 1) && (Qew == data.Q)
    % Expand EW by TS
    for i=1:Mew
      data.EW{i} = repmat(data.EW{i},1,data.TS);
    end
  elseif (Qew == 1) && (data.Q ~= 1) && (TSew == data.TS)
    % Flatten and expend EW by Q
    EW2 = cell(Mew,1);
    for i=1:Mew
      New = size(data.EW{i,1},1);
      EWi = zeros(New,data.Q*data.TS);
      for ts=1:data.TS
        EWi(:,(ts-1)*data.Q+(1:data.Q)) = repmat(data.EW{i,ts},1,data.Q);
      end
      EW2{i} = EWi;
    end
    data.EW = EW2;
  elseif (TSew > 1)
    % Flatten EW
    data.EW = nnfast.seq2con(data.EW);
  end
end

data.Q = data.Q*data.TS;
data.TS = 1;

if isfield(data,'train')
  data.train.mask = nnfast.seq2con(data.train.mask);
end
if isfield(data,'val')
  data.val.mask = nnfast.seq2con(data.val.mask);
end
if isfield(data,'test')
  data.test.mask = nnfast.seq2con(data.test.mask);
end

