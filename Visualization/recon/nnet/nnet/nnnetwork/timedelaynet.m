function out1 = timedelaynet(varargin)
%TIMEDELAYNET Time-delay neural network.
%
%  For an introduction use the Neural Time Series Tool <a href="matlab: doc ntstool">ntstool</a>.
%  Click <a href="matlab:ntstool">here</a> to launch it.
%
%  Time-delay networks can learn to predict a time series Y given past
%  values of another time series X.  It is recommended you use <a href="matlab:doc narxnet">narxnet</a>
%  instead for better results, unless past values of Y will not be available
%  upon deployment.
%
%  <a href="matlab:doc timedelaynet">timedelaynet</a>(inputDelays,hiddenSizes,trainFcn) takes a row vector of
%  input delays, a row vector of N hidden layer sizes and a backpropagation
%  training function, and returns a time-delay network.
%
%  Input, output and output layers sizes are set to 0.  These sizes will
%  automatically be configured to match particular data by <a href="matlab:doc train">train</a>. Or the
%  user can manually configure inputs and outputs with <a href="matlab:doc configure">configure</a>.
%
%  Defaults are used if <a href="matlab:doc timedelaynet">timedelaynet</a> is called with fewer arguments.
%  The default arguments are (1:2,10,'<a href="matlab:doc trainlm">trainlm</a>').
%
%  Here a network is used to solve a time series problem.
%
%    [X,T] = <a href="matlab:doc simpleseries_dataset">simpleseries_dataset</a>;
%    net = <a href="matlab:doc timedelaynet">timedelaynet</a>(1:2,10);
%    [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,T);
%    net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi);
%    <a href="matlab:doc view">view</a>(net)
%    Y = net(Xs,Xi);
%    perf = <a href="matlab:doc perform">perform</a>(net,Y,Ts)
%
%  Once designed the dynamic network can be converted to closed loop with
%  <a href="matlab:doc closeloop">closeloop</a>, it can make predictions a timestep ahead with
%  <a href="matlab:doc removedelay">removedelay</a>, and/or a Simulink diagram can be generated with
%  <a href="matlab:doc gensim">gensim</a>.
%
%  See also PREPARETS, CLOSELOOP, REMOVEDELAY, NARNET, NARXNET.

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
  info = nnfcnNetwork(mfilename,'Time Delay Neural Network',fcnversion, ...
    [ ...
    nnetParamInfo('inputDelays','Input Delays','nntype.pos_inc_int_row',1:2,...
    'Row vector of non-feedback input delays, or 0 for no non-feedback input.'), ...
    nnetParamInfo('hiddenSizes','Hidden Layer Sizes','nntype.strict_pos_int_row',10,...
    'Sizes of 0 or more hidden layers.'), ...
    nnetParamInfo('trainFcn','Training Function','nntype.training_fcn','trainlm',...
    'Function to train the network.'), ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = create_network(param)

  % Feedforward network with input delays
  net = feedforwardnet(param.hiddenSizes,param.trainFcn);
  net.inputWeights{1,1}.delays = param.inputDelays;
  net.inputs{1}.name = 'x';
  net.outputs{net.numLayers}.name = 'y';
  
  % Training
  net.divideMode = 'time';
  
  % Plotting
  net.plotFcns = {'plotperform','plottrainstate','ploterrhist','plotregression',...
    'plotresponse','ploterrcorr','plotinerrcorr'};
end
