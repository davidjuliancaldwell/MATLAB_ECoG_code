function [out1,out2] = learncon(varargin)
%LEARNCON Conscience bias learning function.
%
%  <a href="matlab:doc learncon">learncon</a> is the conscience bias learning function   used to increase
%  the net input to neurons which have the lowest average output until
%  each neuron responds roughly an equal percentage of the time.
%
%  <a href="matlab:doc learncon">learncon</a>(B,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
%    B  - Sx1 bias vector.
%    P  - 1xQ ones vector.
%    Z  - SxQ weighted input vectors.
%    N  - SxQ net input vectors.
%    A  - SxQ output vectors.
%    T  - SxQ layer target vectors.
%    E  - SxQ layer error vectors.
%    gW - SxR gradient with respect to performance.
%    gA - SxQ output gradient with respect to performance.
%    D  - SxS neuron distances.
%    LP - Learning parameters, none, LP = [].
%    LS - Learning state, initially should be = [].
%  and returns
%    dB - Sx1 weight (or bias) change matrix.
%    LS - New learning state.
%
%  Learning occurs according to LEARNCON's learning parameter,
%  shown here with its default value.
%    LP.lr - 0.001 - Learning rate
%
%  <a href="matlab:doc learncon">learncon</a>(CODE) returns useful information for each CODE string:
%    'pnames'    - Returns names of learning parameters.
%    'pdefaults' - Returns default learning parameters.
%    'needg'     - Returns 1 if this function uses gW or gA.
%
%  Here we define a random output A, and bias vector W for a
%  layer with 3 neurons.  We also define the learning rate LR.
%
%    a = rand(3,1);
%    b = rand(3,1);
%    lp.lr = 0.5;
%
%  <a href="matlab:doc learncon">learncon</a> only needs these values to calculate a bias change.
%
%    dW = <a href="matlab:doc learncon">learncon</a>(b,[],[],[],a,[],[],[],[],[],lp,[])
%
%  See also LEARNK, LEARNOS, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9 $  $Date: 2011/02/28 01:28:10 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Learning Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  in1 = varargin{1};
  if ischar(in1)
    switch in1
      case 'info'
        out1 = INFO;
      case 'check_param'
        out1 = check_param(varargin{2});
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    [out1,out2] = apply(varargin{:});
  end
end

function sf = subfunctions
  sf.apply = @apply;
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnLearning(mfilename,'Conscience',fcnversion,subfunctions,...
    true,false,false,false, ...
    [ ...
    nnetParamInfo('lr','Learning Rate','nntype.pos_scalar',0.001,...
    'Relative speed of learning.') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [db,ls] = apply(b,p,z,n,a,t,e,gW,gA,d,lp,ls)
  
  % flatten batch
  q = size(a,2);
  if q ~= 1, a = (1/q)*sum(a,2); end

  % b -> conscience
  c = exp(1-log(b));

  % update conscience
  c = (1-lp.lr) * c + lp.lr * a;

  % conscience -> db
  db = exp(1-log(c)) - b;
end
