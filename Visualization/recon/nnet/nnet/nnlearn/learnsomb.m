function [out1,out2] = learnsomb(varargin)
%LEARNSOM Batch self-organizing map weight learning function.
%
%  <a href="matlab:doc learnsomb">learnsomb</a> is the batch self-organizing map weight learning function.
%
%  <a href="matlab:doc learnsomb">learnsomb</a>(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%  Learning occurs according to LEARNSOMB's learning parameter,
%  shown here with its default value.
%    LP.init_neighborhood -  3 - Initial neighborhood size.
%    LP.steps - 100 - Ordering phase steps.
%
%  <a href="matlab:doc learnsomb">learnsomb</a>(CODE) returns useful information for each CODE string:
%    'pnames'    - Returns names of learning parameters.
%    'pdefaults' - Returns default learning parameters.
%    'needg'     - Returns 1 if this function uses gW or gA.
%
%  Here we define a random input P, output A, and weight matrix W,
%  for a layer with a 2-element input and 6 neurons.  We also calculate
%  the positions and distances for the neurons which are arranged in a
%  2x3 hexagonal pattern.
%
%    p = rand(2,1);
%    a = rand(6,1);
%    w = rand(6,2);
%    pos = <a href="matlab:doc hextop">hextop</a>(2,3);
%    d = <a href="matlab:doc linkdist">linkdist</a>(pos);
%    lp = learnsomb('pdefaults');
%
%  <a href="matlab:doc learnsom">learnsom</a> only needs these values to calculate a weight change.
%
%    ls = [];
%    [dW,ls] = <a href="matlab:doc learnsomb">learnsomb</a>(w,p,[],[],a,[],[],[],[],d,lp,ls)
%
%  See also ADAPT, TRAIN.

% Copyright 2007-2010 The MathWorks, Inc.

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
  info = nnfcnLearning(mfilename,'Self-Organized Map Batch',...
    fcnversion,subfunctions,false,true,true,false, ...
    [ ...
    nnetParamInfo('init_neighborhood','Initial Neighborhood','nntype.pos_scalar',3,...
    'Relative speed of learning.') ...
    nnetParamInfo('steps','Ordering Steps','nntype.pos_int_scalar',1000,...
    'Length of ordering phase in iterations.') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [dw,ls] = apply(w,p,z,n,a,t,e,gW,gA,d,lp,ls)

  [S,R] = size(w);
  [R,Q] = size(p);

  % Initial learning state
  if isempty(ls)
    ls.step = 0;
  end

  % Neighborhood distance
  nd = 1 + (lp.init_neighborhood-1) * (1-ls.step/lp.steps);
  neighborhood = (d <= nd);

  % Activations
  a = a .* double(rand(size(a))<0.9);
  a2 =  neighborhood * a + a;

  suma2 = sum(a2,2);
  loserIndex = (suma2 == 0);
  a3 = a2 ./ suma2(:,ones(1,Q));

  neww = a3*p';
  dw = neww - w;
  dw(loserIndex,:) = 0;

  % Next learning state
  ls.step = ls.step + 1;
end
