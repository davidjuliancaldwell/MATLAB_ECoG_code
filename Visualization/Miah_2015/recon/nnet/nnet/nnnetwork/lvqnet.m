function out1 = lvqnet(varargin)
%LVQNET Learning vector quantization (LVQ) neural network.
%
%  Learning vector quantization networks can be trained to classify
%  inputs according to target classes.  For best results, also try
%  solving classification problems with <a href="matlab:doc patternnet">patternnet</a>.
%
%  <a href="matlab:doc lvqnet">lvqnet</a>(hiddenSize,lvqLR,lvqLF) takes the size of the hidden layer,
%  the LVQ learning rate and the lvq learning function, and returns
%  an LVQ network.
%
%  Input, output and output layers sizes are set to 0.  These sizes will
%  automatically be configured to match particular data by <a href="matlab:doc train">train</a>. Or the
%  user can manually configure inputs and outputs with <a href="matlab:doc configure">configure</a>.
%
%  Defaults are used if <a href="matlab:doc lvqnet">lvqnet</a> is called with fewer arguments.
%  The default arguments are (20,0.01,'learnlv1').
%
%  Here an LVQ network is used to solve a classification problem.
%  
%    [x,t] = <a href="matlab:doc iris_dataset">iris_dataset</a>;
%    net = <a href="matlab:doc lvqnet">lvqnet</a>(20);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    <a href="matlab:doc view">view</a>(net)
%    y = net(x);
%    perf = <a href="matlab:doc perform">perform</a>(net,t,y);
%    classes = <a href="matlab:doc vec2ind">vec2ind</a>(y);
%
%  See also PATTERNNET, COMPETLAYER, SELFORGMAP.

% Mark Beale, 2008-13-2008
% Copyright 2008-2011 The MathWorks, Inc.


%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Network Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin > 0) && ischar(varargin{1}) ...
      && ~strcmpi(varargin{1},'hardlim') && ~strcmpi(varargin{1},'hardlims')
    code = varargin{1};
    switch code
      case 'info',
        out1 = INFO;
      case 'check_param'
        err = check_param(varargin{2});
        if ~isempty(err), nnerr.throw('Args',err); end
        out1 = err;
      case 'create'
        if nargin < 2, error(message('nnet:Args:NotEnough')); end
        param = varargin{2};
        err = nntest.param(INFO.parameters,param);
        if ~isempty(err), nnerr.throw('Args',err); end
        out1 = create_network(param);
        out1.name = INFO.name;
      otherwise,
        % Quick info field access
        try
          out1 = eval(['INFO.' code]);
        catch %#ok<CTCH>
          nnerr.throw(['Unrecognized argument: ''' code ''''])
        end
    end
  else
    [args,param] = nnparam.extract_param(varargin,INFO.defaultParam);
    [param,err] = INFO.overrideStructure(param,args);
    if ~isempty(err), nnerr.throw('Args',err,'Parameters'); end
    net = create_network(param);
    net.name = INFO.name;
    out1 = init(net);
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnNetwork(mfilename,'Feed-Forward Neural Network',fcnversion, ...
    [ ...
    nnetParamInfo('hiddenSize','Hidden Layer Size','nntype.strict_pos_int_scalar',20,...
    'Sizes of 0 or more hidden layers.'), ...
    nnetParamInfo('lvqLR','LVQ Learning Rate','nntype.pos_scalar',0.01,...
    'Function to train the network.'), ...
    nnetParamInfo('lvqLF','LVQ Learning Function','nntype.lvqlrn_fcn','learnlv1',...
    'Function to train the network.'), ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = create_network(param)

  % Architecture
  net = network(1,2,[0;0],[1; 0],[0 0;1 0],[0 1],[0 1]);
  net.layers{1}.size = param.hiddenSize;
  net.inputWeights{1,1}.weightFcn = 'negdist';
  net.layers{1}.transferFcn = 'compet';
  net.outputs{2}.processFcns = {'lvqoutputs'};

  % Performance
  net.performFcn = 'mse';

  % Initialization
  net.initFcn = 'initlay';
  net.layers{1}.initFcn = 'initwb';
  net.inputWeights{1,1}.initFcn = 'midpoint';
  net.layers{2}.initFcn = 'initwb';
  net.layerWeights{2,1}.initFcn = 'initlvq';

  % Learning
  net.inputWeights{1,1}.learnFcn = param.lvqLF;
  net.inputWeights{1,1}.learnParam.lr = param.lvqLR;
  net.trainFcn = 'trainr';
  net.adaptFcn = 'adaptwb';
  
  % Plots
  net.plotFcns = {'plotperform','plottrainstate','ploterrhist','plotconfusion','plotroc'};
end
