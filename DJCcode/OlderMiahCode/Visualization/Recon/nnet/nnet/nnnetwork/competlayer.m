function out1 = competlayer(varargin)
%COMPETLAYER Competitive neural layer.
%
%  Competitive layers learn to classify input vectors into a given number
%  of classes, according to similarity between vectors, with a preference
%  for equal numbers of vectors per class.
%
%  <a href="matlab:doc competlayer">competlayer</a>(numClasses,kohonenLR,conscienceLR) takes the number of
%  clases, the Kohonen weight learning rate and a conscience bias learning
%  rate and returns a competitive layer.
%
%  The input size is set to 0.  Its size will automatically be configured
%  to match particular data by <a href="matlab:doc train">train</a>. Or the user can manually configure
%  the input with <a href="matlab:doc configure">configure</a>.
%
%  Defaults are used if <a href="matlab:doc competlayer">competlayer</a> is called with fewer arguments.
%  The default arguments are (5, 0.01, 0.001).
%
%  When trained on input vectors, competitive layers learn to assign the
%  input vectors to each of the classes, with similar vectors assigned to
%  each class, and with a preference (but not guarantee) that each class
%  will have roughly the same percentage of instances.
%
%  Here a competitive layer is trained to classify 150 iris flowers
%  into 6 classes:
%
%    x = <a href="matlab:doc iris_dataset">iris_dataset</a>;
%    net = <a href="matlab:doc competlayer">competlayer</a>(6);
%    net = <a href="matlab:doc train">train</a>(net,x);
%    <a href="matlab:doc view">view</a>(net)
%    y = net(x);
%    classes = <a href="matlab:doc vec2ind">vec2ind</a>(y);
% 
%  See also SELFORGMAP, PATTERNNET, LVQNET.

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
  info = nnfcnNetwork(mfilename,'Competitive Neural Layer',fcnversion, ...
    [ ...
    nnetParamInfo('numClasses','Number of Classes','nntype.strict_pos_int_scalar',5,...
    'Number of classes, which will be the number of neurons.'), ...
    nnetParamInfo('kohonenLR','Kohonen Learning Rate','nntype.pos_scalar',0.01,...
    'Learning rate for Kohonen associative weight learning rule.'), ...
    nnetParamInfo('conscienceLR','Conscience Learning Rate','nntype.pos_scalar',0.001,...
    'Learning rate for Conscience bias learning rule.'), ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = create_network(param)

  % Architecture
  net = network(1,1,1,1,0,1);
  net.inputWeights{1,1}.weightFcn = 'negdist';
  net.layers{1}.transferFcn = 'compet';
  net.layers{1}.name = 'Competitive';
  net.layers{1}.size = param.numClasses;

  % Learning
  net.inputWeights{1,1}.learnFcn = 'learnk';
  net.inputWeights{1,1}.learnParam.lr = param.kohonenLR;
  net.biases{1}.learnFcn = 'learncon';
  net.biases{1}.learnParam.lr = param.conscienceLR;

  % Adaption
  net.adaptFcn = 'adaptwb';

  % Training
  net.trainFcn = 'trainru';

  % Initialization
  net.initFcn = 'initlay';
  net.layers{1}.initFcn = 'initwb';
  net.biases{1}.initFcn = 'initcon';
  net.inputWeights{1,1}.initFcn = 'midpoint';

  % Plots
  net.plotFcns = {}; % TODO - Plots
end
