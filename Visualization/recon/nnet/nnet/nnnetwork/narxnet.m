function out1 = narxnet(varargin)
%NARXNET Nonlinear auto-associative time-series network with external input.
%
%  For an introduction use the Neural Time Series Tool <a href="matlab: doc ntstool">ntstool</a>.
%  Click <a href="matlab:ntstool">here</a> to launch it.
%
%  Nonlinear autoregressive networks with an external (exogenous) input,
%  can learn to predict a time series Y given past values of Y and another
%  time series X (the external/exogenous) input.
%
%  <a href="matlab:doc narxnet">narxnet</a>(inputDelays,feedbackDelays,hiddenSizes,feedbackMode,trainFcn)
%  takes row vectors of input delays, output-to-input feedback delays, a
%  row vector of N hidden layer sizes, an 'open' or 'closed' feedback mode
%  and a backpropagation training function, and returns a NARX network.
%
%  Input, output and output layers sizes are set to 0.  These sizes will
%  automatically be configured to match particular data by <a href="matlab:doc train">train</a>. Or the
%  user can manually configure inputs and outputs with <a href="matlab:doc configure">configure</a>.
%
%  Defaults are used if <a href="matlab:doc narxnet">narxnet</a> is called with fewer arguments.
%  The default arguments are (1:2,1:2,10,'open','<a href="matlab:doc trainlm">trainlm</a>').
%
%  Here a NARX network is designed. The NARX network has a standard input
%  and an open loop feedback output to an associated feedback input.
%
%    [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%    net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%    [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%    net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%    <a href="matlab:doc view">view</a>(net)
%    Y = net(Xs,Xi,Ai)
%
%  Once designed the dynamic network can be converted to closed loop with
%  <a href="matlab:doc closeloop">closeloop</a>, it can make predictions a timestep ahead with
%  <a href="matlab:doc removedelay">removedelay</a>, and/or used in Simulink with <a href="matlab:doc gensim">gensim</a>.
%
%  See also PREPARETS, CLOSELOOP, REMOVEDELAY, NARNET, TIMEDELAYNET.

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
  info = nnfcnNetwork(mfilename,'NARX Neural Network',fcnversion, ...
    [ ...
    nnetParamInfo('inputDelays','Input Delays','nntype.pos_inc_int_row',[1 2],...
    'Row vector of non-feedback input delays, or 0 for no non-feedback input.'), ...
    nnetParamInfo('feedbackDelays','Feedback delays','nntype.pos_inc_int_row',[1 2],...
    'Row vector of feedback delays, usually starting with 0.'), ...
    nnetParamInfo('hiddenSizes','Hidden Layer Sizes','nntype.strict_pos_int_row',10,...
    'Sizes of 0 or more hidden layers.'), ...
    nnetParamInfo('feedbackMode','Feedback Loop Mode','nntype.feedback_mode','open',...
    'True for open loop feedback, false for closed loop feedback.'), ...
    nnetParamInfo('trainFcn','Training Function','nntype.training_fcn','trainlm',...
    'Function to train the network.'), ...
    ]);
end

function err = check_param(param)
  if (min(param.feedbackDelays) == 0)
    err = 'Minimum feedbackDelay is zero causing a zero-delay loop.';
    % TODO - Handle with separate type
  else
    err = '';
  end
end

function net = create_network(param)

  % Feed-Forward
  net = feedforwardnet(param.hiddenSizes,param.trainFcn);
  net.inputWeights{1,1}.delays = param.inputDelays;
  net.inputs{1}.name = 'x';
  
  % Feedback Output
  net.outputs{net.numLayers}.name = 'y';
  net.outputs{net.numLayers}.feedbackMode = 'open';
  net.inputConnect(1,2) = true;
  net.inputWeights{1,2}.delays = param.feedbackDelays;
  
  % Training
  net.divideFcn = 'dividerand';
  net.divideMode = 'time';
  net.performFcn = 'mse';
  net.trainFcn = param.trainFcn;
  
  % Plotting
  net.plotFcns = {'plotperform','plottrainstate','ploterrhist','plotregression',...
    'plotresponse','ploterrcorr','plotinerrcorr'};
  
  % Open/Closed Loop
  if strcmp(param.feedbackMode,'closed')
    net = closeloop(net);
  end
end
