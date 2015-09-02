function out1 = newgrnn(varargin)
%NEWGRNN Design a generalized regression neural network.
%
%  Generalized regression neural networks are a kind
%  of radial basis network that is often used for function
%  approximation.  GRNNs can be designed very quickly.
%
%  <a href="matlab:doc newgrnn">newgrnn</a>(X,T,SPREAD) takes RxQ matrix of column input vectors,
%  SxQ matrix of column target vectors, and the SPREAD of the radial
%  basis functions (default = 1.0), and returns a new generalized
%  regression network.
%
%  The larger SPREAD is, the smoother the function approximation
%  will be.  To fit data closely, use a SPREAD smaller than the
%  typical distance between input vectors.  To fit the data more
%  smoothly use a larger SPREAD.
%
%  Here a radial basis network is designed from inputs X and targets T,
%  and simulated.
%
%    x = [1 2 3];
%    t = [2.0 4.1 5.9];
%    net = <a href="matlab:doc newgrnn">newgrnn</a>(x,t);
%    y = net(x)
%
%  See also SIM, NEWRB, NEWGRNN, NEWPNN.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.6.11 $ $Date: 2011/05/09 01:01:40 $

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
  info = nnfcnNetwork(mfilename,'Generalized Regression Neural Network',fcnversion, ...
    [ ...
    nnetParamInfo('inputs','Input Data','nntype.data',{},...
    'Input data.'), ...
    nnetParamInfo('targets','Target Data','nntype.data',{},...
    'Target output data.'), ...
    nnetParamInfo('spread','Radial basis spread','nntype.strict_pos_scalar',1,...
    'Distance from radial basis center to 0.5 output.'), ...
    ]);
end

function err = check_param(param)
  err = '';
end

%%
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
  net.layers{1}.size = Q;
  net.inputWeights{1,1}.weightFcn = 'dist';
  net.layers{1}.netInputFcn = 'netprod';
  net.layers{1}.transferFcn = 'radbasn';
  net.layers{2}.size = S;
  net.layerWeights{2,1}.weightFcn = 'dotprod';

  % Weight and Bias Values
  net.b{1} = zeros(Q,1)+sqrt(-log(.5))/param.spread;
  net.iw{1,1} = p';
  net.lw{2,1} = t;
end
