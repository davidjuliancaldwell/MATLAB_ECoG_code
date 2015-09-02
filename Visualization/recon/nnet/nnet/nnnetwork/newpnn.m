function out1 = newpnn(varargin)
%NEWPNN Design a probabilistic neural network.
%
%  Probabilistic neural networks are a kind of radial
%  basis network suitable for classification problems.
%
%  <a href="matlab:doc newpnn">newpnn</a>(X,T,SPREAD) takes an RxQ input matrix X and an SxQ target matrix
%  T, a radial basis function SPREAD and returns a new probabilistic
%  neural network.
%
%  If SPREAD is near zero the network will act as a nearest
%  neighbor classifier.  As SPREAD becomes larger the designed
%  network will take into account several nearby design vectors.
%
%  Here a classification problem is defined with a set of
%  inputs X and class indices Tc.  A PNN is design to fit this data.
%
%    X = [1 2 3 4 5 6 7];
%    Tc = [1 2 3 2 2 3 1];
%    T = <a href="matlab:doc ind2vec">ind2vec</a>(Tc)
%    net = <a href="matlab:doc newpnn">newpnn</a>(X,T);
%    Y = net(P)
%    Yc = <a href="matlab:doc vec2ind">vec2ind</a>(Y)
%
%  See also SIM, IND2VEC, VEC2IND, NEWRB, NEWRBE, NEWGRNN.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.6.12 $ $Date: 2011/05/09 01:01:43 $

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
  info = nnfcnNetwork(mfilename,'Probabilistic Neural Network',fcnversion, ...
    [ ...
    nnetParamInfo('inputs','Input Data','nntype.data',{},...
    'Input data.'), ...
    nnetParamInfo('targets','Target Data','nntype.data',{},...
    'Target output data.'), ...
    nnetParamInfo('spread','Radial basis spread','nntype.strict_pos_scalar',0.1,...
    'Distance from radial basis center to 0.5 output.'), ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = create_network(param)

% Data
  p = param.inputs;
  t = param.targets;
  if iscell(p), p = cell2mat(p); end
  if iscell(t), t = cell2mat(t); end

  % Dimensions
  [R,Q] = size(p);
  [S,Q] = size(t);

  % Architecture
  net = network(1,2,[1;0],[1;0],[0 0;1 0],[0 1]);

  % Simulation
  net.inputs{1}.size = R;
  net.inputWeights{1,1}.weightFcn = 'dist';
  net.layers{1}.netInputFcn = 'netprod';
  net.layers{1}.transferFcn = 'radbas';
  net.layers{1}.size = Q;
  net.layers{2}.size = S;
  net.layers{2}.transferFcn = 'compet';
  net.outputs{2}.exampleOutput = t;

  % Weight and Bias Values
  net.b{1} = zeros(Q,1)+sqrt(-log(.5))/param.spread;
  net.iw{1,1} = p';
  net.lw{2,1} = t;
end
