function [out1,out2] = learnpn(varargin)
%LEARNPN Normalized perceptron weight/bias learning function.
%  
%  <a href="matlab:doc learnpn">learnpn</a> is a weight/bias learning function.  It can result
%  in faster learning than LEARNP when input vectors have
%  widely varying magnitudes.
%
%  <a href="matlab:doc learnpn">learnpn</a>(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%  and returns,
%    dW - SxR weight (or bias) change matrix.
%    LS - New learning state.
%
%  <a href="matlab:doc learnpn">learnpn</a>(CODE) returns useful information for each CODE string:
%    'pnames'    - Returns names of learning parameters.
%    'pdefaults' - Returns default learning parameters.
%    'needg'     - Returns 1 if this function uses gW or gA.
%
%  Here we define a random input P and error E to a layer
%  with a 2-element input and 3 neurons.
%
%    p = rand(2,1);
%    e = rand(3,1);
%
%  Since <a href="matlab:doc learnpn">learnpn</a> only needs these values to calculate a weight
%  change (see Algorithm below), we will use them to do so.
%
%    dW = <a href="matlab:doc learnpn">learnpn</a>([],p,[],[],[],[],e,[],[],[],[],[])
%
%  See also LEARNP, NEWP, ADAPT, TRAIN.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9 $  $Date: 2011/02/28 01:28:21 $

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
  info = nnfcnLearning(mfilename,'Perceptron Normalized',...
    fcnversion,subfunctions,false,true,true,false,[]);
end

function err = check_param(param)
  err = '';
end

function [dw,ls] = apply(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
  R = size(p,1);
  lenp = sqrt(1+sum(p.^2,1));
  pn = p./lenp(ones(1,R),:);
  dw = e*pn';
end
