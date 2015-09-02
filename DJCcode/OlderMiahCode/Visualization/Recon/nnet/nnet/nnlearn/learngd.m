function [out1,out2] = learngd(varargin)
%LEARNGD Gradient descent weight/bias learning function.
%  
%  <a href="matlab:doc learngd">learngd</a> is the gradient descent weight/bias learning function.
%  
%  <a href="matlab:doc learngd">learngd</a>(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
%    W  - SxR weight matrix (or Sx1 bias vector).
%    P  - RxQ input vectors (or ones(1,Q)).
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
%    dW - SxR weight (or bias) change matrix.
%    LS - New learning state.
%
%  Learning occurs according to LEARNGD's learning parameter
%  shown here with its default value.
%    LP.lr - 0.01 - Learning rate
%
%  <a href="matlab:doc learngd">learngd</a>(CODE) return useful information for each CODE string:
%    'pnames'    - Returns names of learning parameters.
%    'pdefaults' - Returns default learning parameters.
%    'needg'     - Returns 1 if this function uses gW or gA.
%
%  Here we define a random gradient gW for a weight going
%  to a layer with 3 neurons, from an input with 2 elements.
%  We also define a learning rate of 0.5.
%
%    gW = rand(3,2);
%    lp.lr = 0.5;
%
%  <a href="matlab:doc learngd">learngd</a> only needs these values to calculate a weight change.
%
%    dW = <a href="matlab:doc learngd">learngd</a>([],[],[],[],[],[],[],gW,[],[],lp,[])
%
%  See also LEARNGDM, NEWFF, NEWCF, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9 $  $Date: 2011/02/28 01:28:11 $

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
  info = nnfcnLearning(mfilename,'Gradient Descent',...
    fcnversion,subfunctions,true,true,true,true, ...
    [ ...
    nnetParamInfo('lr','Learning Rate','nntype.pos_scalar',0.01,...
    'Relative speed of learning.') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [dw,ls] = apply(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
  dw = lp.lr*gW;
end
