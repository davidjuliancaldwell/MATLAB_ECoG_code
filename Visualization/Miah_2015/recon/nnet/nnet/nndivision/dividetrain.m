function [out1,out2,out3,out4,out5,out6] = dividetrain(in1,varargin)
%DIVIDETRAIN Partition indices into training set only.
%
% [trainInd,valInd,testInd] = <a href="matlab:doc dividetrain">dividetrain</a>(Q,trainRatio,valRatio,testRatio)
% takes a number of samples Q and assigns all sample indices 1:Q to
% be training indices, and returns no validation or test indices.
%
% For example, here 250 samples are "divided" up.
%
%   [trainInd,valInd,testInd] = <a href="matlab:doc dividetrain">dividetrain</a>(250)
%
% Here is how to ensure a network will use all data for training and
% none for validation or testing.
%
%   net.<a href="matlab:doc nnproperty.net_divideFcn">divideFcn</a> = '<a href="matlab:doc dividetrain">dividetrain</a>';
%
% See also divideblock, divideind, divideint, dividerand.

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
  info = nnfcnDivision(mfilename,'Training Only',fcnversion,[]);
end

function err = check_param(param)
  err = '';
end

function [trainInd,valInd,testInd] = divide_indices(Q,params)
  trainInd = 1:Q;
  valInd = [];
  testInd = [];
end
