function out1 = newrbe(varargin)
%NEWRBE Design an exact radial basis network.
%
%  Radial basis networks can be used to approximate functions. NEWRBE very
%  designs a radial basis network with zero error on the design vectors.
%
%  <a href="matlab:doc newrbe">newrbe</a>(P,T,SPREAD) takes two or three arguments,
%    P      - RxQ matrix of Q input vectors.
%    T      - SxQ matrix of Q target class vectors.
%    SPREAD - of radial basis functions, default = 1.0.
%  and returns a new exact radial basis network.
%
%  The larger that SPREAD, is the smoother the function approximation
%  will be. Too large a spread can cause numerical problems.
%
%  Here we design a radial basis network, given inputs X and targets T.
%
%    X = [1 2 3];
%    T = [2.0 4.1 5.9];
%    net = <a href="matlab:doc newrbe">newrbe</a>(X,T);
%    X = 1.5;
%    Y = net(P)
%
%  See also SIM, NEWRB, NEWGRNN, NEWPNN.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.6.11 $ $Date: 2011/05/09 01:01:45 $

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
  info = nnfcnNetwork(mfilename,'Radial Basis Network, Exact',fcnversion, ...
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

function net = create_network(param)

  % Format
  p = param.inputs;
  t = param.targets;
  if isa(p,'cell'), p = cell2mat(p); end
  if isa(t,'cell'), t = cell2mat(t); end

  if (size(p,2) ~= size(t,2))
    error(message('nnet:NNData:XTDiffCol'))
  end
  
  % Dimensions
  [R,Q] = size(p);
  [S,Q] = size(t);

  % Architecture
  net = network(1,2,[1;1],[1;0],[0 0;1 0],[0 1]);

  % Simulation
  net.inputs{1}.size = R;
  net.layers{1}.size = Q;
  net.inputWeights{1,1}.weightFcn = 'dist';
  net.layers{1}.netInputFcn = 'netprod';
  net.layers{1}.transferFcn = 'radbas';
  net.layers{2}.size = S;
  net.outputs{2}.exampleOutput = t;

  % Weight and Bias Values
  [w1,b1,w2,b2] = designrbe(p,t,param.spread);

  net.b{1} = b1;
  net.iw{1,1} = w1;
  net.b{2} = b2;
  net.lw{2,1} = w2;
end

%======================================================
function [w1,b1,w2,b2] = designrbe(p,t,spread)

  [r,q] = size(p);
  [s2,q] = size(t);
  w1 = p';
  b1 = ones(q,1)*sqrt(-log(.5))/spread;
  a1 = radbas(dist(w1,p).*(b1*ones(1,q)));
  x = t/[a1; ones(1,q)];
  w2 = x(:,1:q);
  b2 = x(:,q+1);
  
end

%======================================================
