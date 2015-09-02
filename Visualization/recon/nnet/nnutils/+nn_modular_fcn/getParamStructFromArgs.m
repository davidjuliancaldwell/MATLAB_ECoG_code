function [param,errtag] = getParamStructFromArgs(fcn,args)

% Copyright 2010-2012 The MathWorks, Inc.

defaultParam = nn_modular_fcn.parameter_defaults(fcn);
fn = fieldnames(defaultParam);
numArgs = length(args);

% Case 0: No arguments
if (numArgs == 0)
  param = defaultParam;
  errtag = '';
  return;
end

% Case 1: Parameter structure
arg1 = args{1};
if (numel(args)==1) && (isstruct(arg1) || isa(arg1,'nnetParam'))
  param = defaultParam;
  for i=1:length(fn)
    fni = fn{i};
    if isfield(arg1,fni)
      param.(fni) = arg1.(fni);
    end
  end
  errtag = '';
  return
end
  
% Case 2: Name/value pairs
if (rem(numArgs,2) == 0) && ischar(arg1)
  param = defaultParam;
  fnlower = lower(fn);
  for i=1:2:numArgs
    name = args{i};
    if ~ischar(name)
      errtag = 'nnet:Args:BadPairs';
      return
    end
    j = nnstring.first_match(lower(name),fnlower);
    if isempty(j)
      errtag = 'nnet:Args:BadPairs';
      return
    end
    value = args{i+1};
    param.(fn{j}) = value;
  end
  errtag = '';
  return
end

% Case 3: Fill in parameter values
if numel(args) <= numel(fn)
  param = defaultParam;
  for i=1:numel(args)
    param.(fn{i}) = args{i};
  end
  errtag = '';
  return;
end

param = [];
errtag = 'nnet:Args:IncorrectNum';
