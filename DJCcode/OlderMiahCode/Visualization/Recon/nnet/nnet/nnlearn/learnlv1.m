function [out1,out2] = learnlv1(varargin)
%LEARNLV1 LVQ1 weight learning function.
%
%  <a href="matlab:doc learnlv1">learnlv1</a> is the LVQ1 weight learning function.
%
%  <a href="matlab:doc learnlv1">learnlv1</a>(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
%    W  - SxR weight matrix (or Sx1 bias vector).
%    P  - RxQ input vectors (or ones(1,Q)).
%    Z  - SxQ weighted input vectors.
%    N  - SxQ net input vectors.
%    A  - SxQ output vectors.
%    T  - SxQ layer target vectors.
%    E  - SxQ layer error vectors.
%    gW - SxR weight gradient with respect to performance.
%    gA - SxQ output gradient with respect to performance.
%    D  - SxS neuron distances.
%    LP - Learning parameters, none, LP = [].
%    LS - Learning state, initially should be = [].
%  and returns,
%    dW - SxR weight (or bias) change matrix.
%    LS - New learning state.
%
%  Learning occurs according to LEARNLV1's learning parameter,
%  shown here with its default value.
%    LP.lr - 0.01 - Learning rate
%
%  <a href="matlab:doc learnlv1">learnlv1</a>(CODE) returns useful information for each CODE string:
%    'pnames'    - Returns names of learning parameters.
%    'pdefaults' - Returns default learning parameters.
%    'needg'     - Returns 1 if this function uses gW or gA.
%
%  Here we define a random input P, output A, weight matrix W, and
%  output gradient gA for a layer with a 2-element input and 3 neurons.
%  We also define the learning rate LR.
%
%    p = rand(2,1);
%    w = rand(3,2);
%    a = <a href="matlab:doc compet">compet</a>(<a href="matlab:doc negdist">negdist</a>(w,p));
%    gA = [-1;1; 1];
%    lp.lr = 0.5;
%
%  <a href="matlab:doc learnlv1">learnlv1</a> only needs these values to calculate a weight change.
%
%    dW = <a href="matlab:doc learnlv1">learnlv1</a>(w,p,[],[],a,[],[],[],gA,[],lp,[])
%
%  See also LEARNLV2, ADAPT, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9 $

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
  info = nnfcnLearning(mfilename,'LVQ1',...
    fcnversion,subfunctions,false,true,true,true, ...
    nnetParamInfo('lr','Learning Rate','nntype.pos_scalar',0.01,...
    'Relative speed of learning.') ...
    );
end

function err = check_param(param)
  err = '';
end

function [dw,ls] = apply(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
  
  [S,R] = size(w);
  Q = size(p,2);
  pt = p';
  dw = zeros(S,R);

  for q=1:Q
    i = find(a(:,q));
    if any(gA(:,q) ~= 0)

      % Move incorrect winner away from input
      dw(i,:) = dw(i,:) - lp.lr*(pt(q,:)-w(i,:));

    else

      % Move correct winner toward input
      dw(i,:) = dw(i,:) + lp.lr*(pt(q,:)-w(i,:));
    end
  end
end
