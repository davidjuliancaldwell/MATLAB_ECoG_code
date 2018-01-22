function [out1,out2] = learnsom(varargin)
%LEARNSOM Self-organizing map weight learning function.
%
%  <a href="matlab:doc learnsom">learnsom</a> is the self-organizing map weight learning function.
%
%  <a href="matlab:doc learnsom">learnsom</a>(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%  Learning occurs according to LEARNSOM's learning parameter,
%  shown here with its default value.
%    LP.order_lr    -  0.9 - Ordering phase learning rate.
%    LP.order_steps - 1000 - Ordering phase steps.
%    LP.tune_lr     - 0.02 - Tuning phase learning rate.
%    LP.tune_nd     -    1 - Tuning phase neighborhood distance.
%
%  <a href="matlab:doc learnsom">learnsom</a>(CODE) returns useful information for each CODE string:
%    'pnames'    - Returns names of learning parameters.
%    'pdefaults' - Returns default learning parameters.
%    'needg'     - Returns 1 if this function uses gW or gA.
%
%  Here we define a random input P, output A, and weight matrix W,
%  for a layer with a 2-element input and 6 neurons.  We also calculate
%  the positions and distances for the neurons which are arranged in a
%  2x3 hexagonal pattern. Then we define the four learning parameters.
%
%    p = rand(2,1);
%    a = rand(6,1);
%    w = rand(6,2);
%    pos = <a href="matlab:doc hextop">hextop</a>(2,3);
%    d = <a href="matlab:doc linkdist">linkdist</a>(pos);
%    lp.order_lr = 0.9;
%    lp.order_steps = 1000;
%    lp.tune_lr = 0.02;
%    lp.tune_nd = 1;
%
%  <a href="matlab:doc learnsom">learnsom</a> only needs these values to calculate a weight change.
%
%    ls = [];
%    [dW,ls] = learnsom(w,p,[],[],a,[],[],[],[],d,lp,ls)
%
%  See also ADAPT, TRAIN.

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
  info = nnfcnLearning(mfilename,'Self-Organized Map Incremental',...
    fcnversion,subfunctions,false,true,true,false, ...
    [ ...
    nnetParamInfo('order_lr','Ordering Phase Learning Rate','nntype.pos_scalar',0.9,...
    'Relative speed of learning during ordering phase.') ...
    nnetParamInfo('order_steps','Ordering Steps','nntype.pos_scalar',1000,...
    'Number of steps for ordering phase.') ...
    nnetParamInfo('tune_lr','Tuning Learning Rate','nntype.pos_scalar',0.02,...
    'Relative speed of learning for tuning phase.') ...
    nnetParamInfo('tune_nd','Tuning Neighborhood Distance','nntype.pos_scalar',1,...
    'Neighborhood distance for tuning phase.') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [dw,ls] = apply(w,p,z,n,a,t,e,gW,gA,d,lp,ls)

  % Initial learning state
  if isempty(ls)
    ls.step = 0;
    ls.nd_max = max(max(d));
  end

  % Neighborhood and learning rate
  if (ls.step < lp.order_steps)
    percent = 1 - ls.step/lp.order_steps;
    nd = 1.00001 + (ls.nd_max-1) * percent;
    lr = lp.tune_lr + (lp.order_lr-lp.tune_lr) * percent;
  else
    nd = lp.tune_nd + 0.00001;
    lr = lp.tune_lr * lp.order_steps/ls.step;
  end

  % Bubble neighborhood
  a2 = 0.5*(a + (d < nd)*a);

  % Instar rule
  [S,R] = size(w);
  [R,Q] = size(p);
  pt = p';
  lr_a = lr * a2;
  dw = zeros(S,R);
  for q=1:Q
    dw = dw + lr_a(:,q+zeros(1,R)) .* (pt(q+zeros(S,1),:)-w);
  end

  % Next learning state
  ls.step = ls.step + 1;
end
