function out1 = fitnet(varargin)
%FITNET Function fitting neural network.
%
%  For an introduction use the Neural Fitting Tool <a href="matlab: doc nftool">nftool</a>.
%  Click <a href="matlab:nftool">here</a> to launch it.
%
%  Two (or more) layer fitting networks can fit any finite input-output
%  relationship arbitrarily well given enough hidden neurons.
%
%  <a href="matlab:doc fitnet">fitnet</a>(hiddenSizes,trainFcn) takes a row vector of N hidden layer
%  sizes, and a backpropagation training function, and returns
%  a feed-forward neural network with N+1 layers.
%
%  Input, output and output layers sizes are set to 0.  These sizes will
%  automatically be configured to match particular data by <a href="matlab:doc train">train</a>. Or the
%  user can manually configure inputs and outputs with <a href="matlab:doc configure">configure</a>.
%
%  Defaults are used if <a href="matlab:doc fitnet">fitnet</a> is called with fewer arguments.
%  The default arguments are (10,'<a href="matlab:doc trainlm">trainlm</a>').
%
%  Here a fitting network is used to solve a simple fitting problem:
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc fitnet">fitnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    <a href="matlab:doc view">view</a>(net)
%    y = net(x);
%    perf = <a href="matlab:doc perform">perform</a>(net,t,y)
%
%  See also FEEDFORWARDNET, PATTERNNET.

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
  info = nnfcnNetwork(mfilename,'Function Fitting Neural Network',fcnversion, ...
    [ ...
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
  net = feedforwardnet(param.hiddenSizes,param.trainFcn);
  net.plotFcns = [net.plotFcns {'plotfit'}];
end
