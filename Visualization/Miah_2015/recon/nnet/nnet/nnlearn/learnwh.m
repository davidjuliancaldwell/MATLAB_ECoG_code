function [out1,out2] = learnwh(varargin)
%LEARNWH Widrow-Hoff weight/bias learning function.
%  
%  Syntax
%  
%    [dW,LS] = learnwh(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    [db,LS] = learnwh(b,ones(1,Q),Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learnwh(code)
%
%  Description
%
%    LEARNWH is the Widrow-Hoff weight/bias learning function,
%    and is also known as the delta or least mean squared (LMS) rule.
%  
%    LEARNWH(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
%      W  - SxR weight matrix (or b, an Sx1 bias vector).
%      P  - RxQ input vectors (or ones(1,Q)).
%      Z  - SxQ weighted input vectors.
%      N  - SxQ net input vectors.
%      A  - SxQ output vectors.
%      T  - SxQ layer target vectors.
%      E  - SxQ layer error vectors.
%      gW - SxR gradient with respect to performance.
%      gA - SxQ output gradient with respect to performance.
%      D  - SxS neuron distances.
%      LP - Learning parameters, none, LP = [].
%      LS - Learning state, initially should be = [].
%    and returns,
%      dW - SxR weight (or bias) change matrix.
%      LS - New learning state.
%
%    Learning occurs according to LEARNWH's learning parameter,
%    shown here with its default value.
%      LP.lr - 0.01 - Learning rate
%
%    LEARNWH(CODE) returns useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%  Examples
%
%    Here we define a random input P and error E to a layer
%    with a 2-element input and 3 neurons.  We also define the
%    learning rate LR learning parameter.
%
%      p = rand(2,1);
%      e = rand(3,1);
%      lp.lr = 0.5;
%
%    Since LEARNWH only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%
%      dW = learnwh([],p,[],[],[],[],e,[],[],[],lp,[])
%
%  Network Use
%
%    You can create a standard network that uses LEARNWH with NEWLIN.
%
%    To prepare the weights and the bias of layer i of a custom network
%    to learn with LEARNWH:
%    1) Set NET.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> to 'trainb'.
%       NET.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a> will automatically become TRAINB's default parameters.
%    2) Set NET.<a href="matlab:doc nnproperty.net_adaptFcn">adaptFcn</a> to 'adaptwb'.
%       NET.<a href="matlab:doc nnproperty.net_adaptParam">adaptParam</a> will automatically become TRAINS's default parameters.
%    3) Set each NET.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_learnFcn">learnFcn</a> to 'learnwh'.
%       Set each NET.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_learnFcn">learnFcn</a> to 'learnwh'.
%       Set NET.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_learnFcn">learnFcn</a> to 'learnwh'.
%       Each weight and bias learning parameter property will automatically
%       be set to LEARNWH's default parameters.
%
%    To train the network (or enable it to adapt):
%    1) Set NET.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a> (NET.<a href="matlab:doc nnproperty.net_adaptParam">adaptParam</a>) properties to desired values.
%    2) Call TRAIN (ADAPT).
%
%    See NEWLIN for adaption and training examples.
%    
%  Algorithm
%
%    LEARNWH calculates the weight change dW for a given neuron from the
%    neuron's input P and error E, and the weight (or bias) learning
%    rate LR, according to the Widrow-Hoff learning rule:
%
%      dw = lr*e*pn'
%
%  See also NEWLIN, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 11-31-97, MB
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9 $  $Date: 2011/02/28 01:28:24 $

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
  info = nnfcnLearning(mfilename,'Widrow-Hoff',...
    fcnversion,subfunctions,true,true,true,false, ...
    [ ...
    nnetParamInfo('lr','Learning Rate','nntype.pos_scalar',0.01,...
    'Relative speed of learning.') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [dw,ls] = apply(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
  dw = lp.lr*e*p';
end
