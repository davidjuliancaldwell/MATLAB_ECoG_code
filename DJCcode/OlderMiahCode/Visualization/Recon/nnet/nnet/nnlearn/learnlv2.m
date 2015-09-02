function [out1,out2] = learnlv2(varargin)
%LEARNLV2 LVQ 2.1 weight learning function.
%
%  <a href="matlab:doc learnlv2">learnlv2</a> is the LVQ2 weight learning function.
%
%  <a href="matlab:doc learnlv2">learnlv2</a>(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%    LP.window - 0.25 - Window size (0 to 1, typically 0.2 to 0.3).
%
%  <a href="matlab:doc learnlv2">learnlv2</a>(CODE) returns useful information for each CODE string:
%    'pnames'    - Returns names of learning parameters.
%    'pdefaults' - Returns default learning parameters.
%    'needg'     - Returns 1 if this function uses gW or gA.
%
%  Here we define a sample input P, output A, weight matrix W, and
%  output gradient gA for a layer with a 2-element input and 3 neurons.
%  We also define the learning rate LR.
%
%    p = [0;1];
%    w = [-1 1; 1 0; 1 1];
%    n = <a href="matlab:doc negdist">negdist</a>(w,p);
%    a = <a href="matlab:doc compet">compet</a>(n);
%    gA = [-1;1;1];
%    lp.lr = 0.5;
%    lp.window = 0.25;
%
%  <a href="matlab:doc learnlv2">learnlv2</a> only needs these values to calculate a weight change.
%
%    dW = learnlv2(w,p,[],n,a,[],[],[],gA,[],lp,[])
%
%  See also LEARNLV1, ADAPT, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2011/02/28 01:28:18 $

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
  info = nnfcnLearning(mfilename,'LVQ2',...
    fcnversion,subfunctions,false,true,true,true, ...
    [ ...
    nnetParamInfo('lr','Learning Rate','nntype.pos_scalar',0.01,...
    'Relative speed of learning.') ...
    nnetParamInfo('window','Window Size','nntype.pos_scalar',0.25,...
    'Limit defining when learning occurs.') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [dw,ls] = apply(w,p,z,n,a,t,e,gW,gA,d,lp,ls)

  [S,R] = size(w);
  Q = size(p,2);
  pt = p';
  dw = zeros(S,R);

  % For each q...
  for q=1:Q

    % Find closest neuron k1
    nq = n(:,q);
    k1 = find(nq == max(nq));
    k1 = k1(1);

    % Find next closest neuron k2
    nq(k1) = -inf;
    k2 = find(nq == max(nq));
    k2 = k2(1);

    % If one neuron is in correct class and the other is not...
    % (Which happens if both neurons have no error, or both have error)
    if (abs(gA(k1,q)) == abs(gA(k2,q)))

      % indicate the incorrect neuron with i, the other with j
      if gA(k1,q) ~= 0
        i = k1;
        j = k2;
      else
        i = k2;
        j = k1;
      end

      % and if x falls into the window...
      d1 = abs(n(k1,q)); % Shorter distance
      d2 = abs(n(k2,q)); % Greater distance
      if (d1/d2 > ((1-lp.window)/(1+lp.window)))

        % then move incorrect neuron away from input,
        % and the correct neuron towards the input
        ptq = pt(q,:);
        dw(i,:) = dw(i,:) - lp.lr*(ptq-w(i,:));
        dw(j,:) = dw(j,:) + lp.lr*(ptq-w(j,:));
      end
    end
  end
end
