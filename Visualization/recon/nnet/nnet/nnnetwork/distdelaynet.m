function out1 = distdelaynet(varargin)
%DISTDELAYNET Distributed delay neural network.
%
%  Distributed delay networks with two (or more) layers can learn to
%  predict any dynamic output from past inputs given enough hidden
%  neurons and enough input and layer delays.
%
%  <a href="matlab:doc distdelaynet">distdelaynet</a>(delays,hiddenSizes,trainFcn) takes a row
%  cell array of N delay row vectors, N-1 hidden layer sizes, and a
%  backpropagation training function, and returns a distributed delay
%  neural network with N layers.
%
%  Input, output and output layers sizes are set to 0.  These sizes will
%  automatically be configured to match particular data by <a href="matlab:doc train">train</a>. Or the
%  user can manually configure inputs and outputs with <a href="matlab:doc configure">configure</a>.
%
%  Defaults are used if <a href="matlab:doc distdelaynet">distdelaynet</a> is called with fewer arguments.
%  The default arguments are (1:2,1:2,10,'<a href="matlab:doc trainlm">trainlm</a>').
%
%  Here a distributed delay network is used to solve a time series problem.
%
%    [X,T] = <a href="matlab:doc simpleseries_dataset">simpleseries_dataset</a>;
%    net = <a href="matlab:doc distdelaynet">distdelaynet</a>({1:2,1:2},10);
%    [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,T);
%    net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%    <a href="matlab:doc view">view</a>(net)
%    Y = net(Xs,Xi,Ai);
%    perf = <a href="matlab:doc perform">perform</a>(net,Y,Ts)
%
%  Once designed the dynamic network can be converted to make predictions a
%  timestep ahead with <a href="matlab:doc removedelay">removedelay</a> or used in Simulink with <a href="matlab:doc gensim">gensim</a>.
%
%  See also REMOVEDELAY, NARXNET, NARNET, TIMEDELAYNET.

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
  info = nnfcnNetwork(mfilename,'Distributed Delay Neural Network',fcnversion, ...
    [ ...
    nnetParamInfo('delays','Delays','nntype.cellrow_delayvec',{[1 2] [1 2]},...
    'Row cell array of row delay vectors for each layer''s weight.'), ...
    nnetParamInfo('hiddenSizes','Hidden Layer Sizes','nntype.strict_pos_int_row',10,...
    'Sizes of 0 or more hidden layers.'), ...
    nnetParamInfo('trainFcn','Training Function','nntype.training_fcn','trainlm',...
    'Function to train the network.'), ...
    ]);
end

function err = check_param(param)
  ndelays = length(param.delays);
  nlayers = length(param.hiddenSizes) + 1;
  if ndelays ~= nlayers
    err = ['The number of delay vectors ' num2str(ndelays) ...
      ' is not equal the number of layers ' num2str(nlayers) '.'];
  else
    err = '';
  end
end

function net = create_network(param)
  net = feedforwardnet(param.hiddenSizes,param.trainFcn);
  net.inputWeights{1,1}.delays = param.delays{1};
  for i=1:length(param.hiddenSizes)
    net.layerWeights{i+1,i}.delays = param.delays{i+1};
  end
  net.divideMode = 'time';
  net.plotFcns = [net.plotFcns {'plotresponse','ploterrcorr','plotinerrcorr'}];
end
