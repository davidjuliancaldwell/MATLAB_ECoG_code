function [out1,out2,out3,out4,out5,out6] = divideind(in1,varargin)
%DIVIDEIND Partition indices into three sets using specified indices.
%
% [trainInd,valInd,testInd] = <a href="matlab:doc divideind">divideind</a>(Q,trainInd,valInd,testInd)
% takes a number of samples Q and training, validation and test indices.
% The indices are then returned after removing any indices greater
% than Q.  Note that some indices in the range 1:Q may not be assigned
% to any of the three sets.
%
% For example, here 20 samples are divided training, validation and test
% indices, so that only 16 are actually used.
%
%   [trainInd,valInd,testInd] = <a href="matlab:doc divideind">divideind</a>(20,1:8,9:12,14:16)
%
% Here is how to ensure a network will perform the same kind of data
% division when it is trained:
%
%   net.<a href="matlab:doc nnproperty.net_divideFcn">divideFcn</a> = '<a href="matlab:doc divideind">divideind</a>';
%   net.<a href="matlab:doc nnproperty.net_divideParam">divideParam</a>.<a href="matlab:doc nnparam.trainInd">trainInd</a> = 1:8;
%   net.<a href="matlab:doc nnproperty.net_divideParam">divideParam</a>.<a href="matlab:doc nnparam.valInd">valInd</a> = 9:12;
%   net.<a href="matlab:doc nnproperty.net_divideParam">divideParam</a>.<a href="matlab:doc nnparam.testInd">testInd</a> = 14:16.
%
% See also divideblock, divideint, dividerand, dividetrain.

% Copyright 2006-2010 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Data Division Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  if ischar(in1)
    switch in1
      case 'info'
        out1 = INFO;
      case 'check_param'
        out1 = check_param(varargin{1});
        
    otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me,
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
    return
  end
  if nargin == 1
    params = struct(INFO.parameterDefaults);
  else
    in2 = varargin{1};
    if isstruct(in2)
      params = in2;
    elseif isa(in2,'nnetParam')
      params = struct(in2);
    else
      params = INFO.parameterStructure(varargin);
    end
  end
  if isscalar(in1) && isnumeric(in1)
    [out1,out2,out3] = divide_indices(in1,params);
  % NNET 6.0 Compatibility
  else
    Q = numsamples(in1);
    [out4,out5,out6] = divide_indices(Q,params);
    out1 = getsamples(in1,out4);
    out2 = getsamples(in1,out5);
    out3 = getsamples(in1,out6);
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnDivision(mfilename,'Index',fcnversion, ...
    [ ...
    nnetParamInfo('trainInd','Training Indices','nntype.index_row',[],...
    'The indices for training vectors.'), ...
    nnetParamInfo('valInd','Validation Indices','nntype.index_row',[],...
    'The indices for validation vectors.'), ...
    nnetParamInfo('testInd','Test Indices','nntype.index_row',[],...
    'The indices for test vectors.') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [trainInd,valInd,testInd] = divide_indices(Q,params)
  trainInd = params.trainInd(params.trainInd <= Q);
  trainInd = unique(trainInd);
  valInd = params.valInd(params.valInd <= Q);
  valInd = unique(valInd);
  [i,itrain,ival] = intersect(trainInd,valInd);
  valInd(ival) = [];
  testInd = params.testInd(params.testInd <= Q);
  testInd = unique(testInd);
  [i,itrain,itest] = intersect(trainInd,testInd);
  testInd(itest) = [];
  [i,ival,itest] = intersect(valInd,testInd);
  testInd(itest) = [];
end
