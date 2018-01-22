function out1 = linearlayer(varargin)
%LINEARLAYER Linear neural layer.
%
%  Linear layers can be trained to model static and dynamic linear
%  systems, given a low enough learning rate to be stable.
%
%  <a href="matlab:doc linearlayer">linearlayer</a>(inputDelays,widrowHoffLR) takes a row vector of input
%  delays and a Widrow-Hoff learning rate and returns a linear layer.
%
%  Input, output and layer sizes are set to 0.  These sizes will
%  automatically be configured to match particular data by TRAIN. Or the
%  user can manually configure inputs and outputs with CONFIGURE.
%
%  Defaults are used if <a href="matlab:doc linearlayer">linearlayer</a> is called with fewer arguments.
%  The default arguments are (0,0.01).
%
%  Here a linear layer is used to solve a time series problem.
%
%    x = {0 -1 1 1 0 -1 1 0 0 1};
%    t = {0 -1 0 2 1 -1 0 1 0 1};
%    net = <a href="matlab:doc linearlayer">linearlayer</a>(0:2,0.01);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    <a href="matlab:doc view">view</a>(net)
%    y = net(x);
%    perf = <a href="matlab:doc perform">perform</a>(net,t,y)
%
%  For static problems <a href="matlab:doc maxlinlr">maxlinlr</a> returns an upper bound on the
%  Widrow-Hoff learning rate for stable learning.
%
%  See also NEWLIND, MAXLINLR.

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
  info = nnfcnNetwork(mfilename,'Linear Neural Layer',fcnversion, ...
    [ ...
    nnetParamInfo('inputDelays','Input Delays','nntype.delayvec',0,...
    'Input delay vector.'), ...
    nnetParamInfo('widrowHoffLR','Widrow-Hoff Learning Rate','nntype.pos_scalar',0.01,...
    'Learning rate for Widrow-Hoff learning rule.'), ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = create_network(param)

  % Architecture
  net = network(1,1,1,1,0,1,1);
  net.inputWeights{1,1}.delays = param.inputDelays;
  net.layers{1}.name = 'Linear';

  % Performance
  net.performFcn = 'mse';

  % Learning (Adaption and Training)
  net.inputWeights{1,1}.learnFcn = 'learnwh';
  net.biases{1}.learnFcn = 'learnwh';
  net.inputWeights{1,1}.learnParam.lr = param.widrowHoffLR;
  net.biases{1}.learnParam.lr = param.widrowHoffLR;

  % Adaption
  net.adaptFcn = 'adaptwb';

  % Training
  net.trainFcn = 'trainb';

  % Initialization
  net.initFcn = 'initlay';
  net.layers{1}.initFcn = 'initwb';
  net.inputWeights{1,1}.initFcn = 'initzero';
  net.biases{1}.initFcn = 'initzero';
  net = init(net);

  % Plots
  net.plotFcns = {'plotperform','plottrainstate','ploterrhist'};
end
