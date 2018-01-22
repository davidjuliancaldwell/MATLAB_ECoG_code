function [trainV,valV,testV] = dividevec(p,t,valPercent,testPercent)
%DIVIDEVEC Divide problem vectors into training, validation and test vectors.
%
% Obsoleted in R2008b NNET 6.0.  Last used in R2007b NNET 5.1.
%
% Syntax
%
%   [trainV,valV,testV] = dividevec(p,t,valPercent,testPercent)
%
% Description
%
%   DIVIDEVEC is used to separate a set of input and target data into
%   groups of vectors for training, validating network performance during
%   training so that training stops early if it attempts to overfit the training
%   data, and test data used for an independent measure of how the network
%   might be expected to perform on data it was not trained on.
% 
%   DIVIDEVEC(P,T,valPercent,testPercent) takes the following inputs,
%     P - RxQ matrix of inputs, or cell array of input matices.
%     T - SxQ matrix of targets, or cell array of target matrices.
%     valPercent - Fraction of column vectors to use for validation.
%     testPercent - Fraction of column vectors to use for test.
%   and returns:
%     trainV.P, .T, .indices - Training vectors and their original indices
%     valV.P, .T, .indices - Validation vectors and their original indices
%     testV.P, .T, .indices - Test vectors and their original indices
%
% Examples
%
%   Here 1000 3-element input and 2-element target vectors are  created:
%   
%     p = rands(3,1000);
%     t = [p(1,:).*p(2,:); p(2,:).*p(3,:)];
%
%  Here they are divided up into training, validation and test sets.
%  Validation and test sets contain 20% of the vectors each, leaving
%  60% of the vectors for training.
%
%     [trainV,valV,testV] = dividevec(p,t,0.20,0.20);
%
%  Now a network is created and trained with the data.
%
%     net = newff(minmax(p),[10 size(t,1)]);
%     net = train(net,trainV.P,trainV.T,[],[],valV,testV);
%
% See also con2seq, seq2con.

% Copyright 2005-2011 The MathWorks, Inc.

if nargin < 4, testPercent = 0.0; end
if nargin < 3, valPercent = 0.0; end
if nargin < 2, error(message('nnet:Args:NotEnough')),end

err = nncheckpt(p,t,'P','T'); if ~isempty(err), nnerr.throw(err); end

[p,mode] = nnpackdata(p);
[t,mode] = nnpackdata(t);

TS = size(p,2);
Q = size(p{1,1},2);
R = size(p,1);
S = size(t,1);

numValidate = floor(valPercent * Q);
numTest = floor(testPercent * Q);
numTrain = Q - numValidate - numTest;

i = randperm(Q);
i1 = sort(i(1:numTrain));
i2 = sort(i(numTrain+(1:numValidate)));
i3 = sort(i(numTrain+numValidate+(1:numTest)));

trainV.P = cell(R,TS);
trainV.T = cell(S,TS);
valV.P = cell(R,TS);
valV.T = cell(S,TS);
testV.P = cell(R,TS);
testV.T = cell(S,TS);

for ts=1:TS
  for i=1:R
    pi = p{i,ts};
    trainV.P{i,ts} = pi(:,i1);
    valV.P{i,ts} = pi(:,i2);
    testV.P{i,ts} = pi(:,i3);
  end
  for i=1:S
    ti = t{i,ts};
    trainV.T{i,ts} = ti(:,i1);
    valV.T{i,ts} = ti(:,i2);
    testV.T{i,ts} = ti(:,i3);
  end
end

trainV.P = nnunpackdata(trainV.P,mode);
trainV.T = nnunpackdata(trainV.T,mode);
trainV.indices = i1;
valV.P = nnunpackdata(valV.P,mode);
valV.T = nnunpackdata(valV.T,mode);
valV.indices = i2;
testV.P = nnunpackdata(testV.P,mode);
testV.T = nnunpackdata(testV.T,mode);
testV.indices = i3;

function [d,mode] = nnpackdata(d)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2005-2010 The MathWorks, Inc.

if isnumeric(d)
  d = {d};
  mode = 0;
elseif iscell(d)
  mode = 1;
else
  d = []
  mode = -1;
end

function err = nncheckpt(p,t,pname,tname)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2005-2010 The MathWorks, Inc.

if nargin < 4, error(message('nnet:Args:NotEnough')); end

err = [];

err = nntype.data('check',p,pname);
if ~isempty(err), return; end
err = nntype.data('check',t,tname);
if ~isempty(err), return; end

if isnumeric(p) ~= isnumeric(t)
  err = [pname ' and ' tname ' must be both numeric or both cell.'];
  return;
end
if iscell(p) ~= iscell(t)
  err = [pname ' and ' tname ' must be both numeric or both cell.'];
  return
end

if isnumeric(p)
  Qp = size(p,2);
  Qt = size(t,2);
  if (Qp ~= Qt)
    err = [pname ' and ' tname ' have different numbers of columns.'];
    return
  end
else
  TSp = size(p,2);
  TSt = size(t,2);
  if (TSp ~= TSt)
    err = [pname ' and ' tname ' have different numbers of columns.'];
    return
  end
  Qp = size(p{1,1},2);
  Qt = size(t{1,1},2);
  if (Qp ~= Qt)
    err = [pname '{i,j} and ' tname '{i,j} have different numbers of columns.'];
    return
  end
end

