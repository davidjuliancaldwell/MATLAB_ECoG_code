function out1 = perceptron(varargin)
%PERCEPTRON Perceptron.
%
%  Perceptrons are provide for historical interest. For much better
%  results use <a href="matlab:doc patternnet">patternnet</a>. Often when people refer to perceptrons
%  they are referring to feed-forward pattern recognition networks. The
%  original perceptron implemented here can only solve very simple problems.
% 
%  Perceptrons can learn to solve a narrow class of classification problems.
%  Their significance is they have a simple learning rule and were one of
%  the first neural networks to reliably solve a given class of problems.
%  Perceptrons reliably solve linearly separable classification problems.
%
%  <a href="matlab:doc perceptron">perceptron</a>(hardlimitTF,perceptronLF) takes a hardlimit transfer function
%  and a perceptron learning function and returns a perceptron.
%
%  Input, output and output layers sizes are set to 0.  These sizes will
%  automatically be configured to match particular data by <a href="matlab:doc train">train</a>. Or the
%  user can manually configure inputs and outputs with <a href="matlab:doc configure">configure</a>.
%
%  Defaults are used if <a href="matlab:doc perceptron">perceptron</a> is called with fewer arguments.
%  The default arguments are ('<a href="matlab:doc hardlim">hardlim</a>','<a href="matlab:doc learnp">learnp</a>').
%
%  Here a perceptron is used to solve a simple fitting problem, the
%  linearly separable logical OR.
%
%    x = [0 0 1 1; 0 1 0 1];
%    t = [0 1 1 1];
%    net = <a href="matlab:doc perceptron">perceptron</a>;
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    <a href="matlab:doc view">view</a>(net)
%    y = net(x);
%
%  See also PATTERNNET, LVQNET, COMPETLAYER, SELFORGMAP.

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
  info = nnfcnNetwork(mfilename,'Perceptron',fcnversion, ...
    [ ...
    nnetParamInfo('hardlimitTF','Hard-Limit Transfer Function','nntype.hardlimit_fcn','hardlim',...
    'Either hard limit or symmetric hard limit.'), ...
    nnetParamInfo('perceptronLF','Perceptron Learning Function','nntype.perceptlrn_fcn','learnp',...
    'Either perceptron or normalized perceptron learning rule.'), ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = create_network(param)

  % Architecture
  net = network(1,1,1,1,0,1);
  net.layers{1}.transferFcn = param.hardlimitTF;
  net.layers{1}.name = 'Hard Limit';
  
  % Learning (Adaption and Training)
  net.inputWeights{1,1}.learnFcn = param.perceptronLF;
  net.biases{1}.learnFcn = param.perceptronLF;

  % Adaption
  net.adaptFcn = 'adaptwb';

  % Training
  net.trainFcn = 'trainc';
  net.divideFcn = 'dividetrain';
  net.performFcn = 'mae';

  % Initialization
  net.initFcn = 'initlay';
  net.layers{1}.initFcn = 'initwb';
  net.biases{1}.initFcn = 'initzero';
  net.inputWeights{1,1}.initFcn = 'initzero';
  net = init(net);

  % Plots
  net.plotFcns = {'plotperform','plottrainstate','plotconfusion'};
end
