function out1 = newhop(varargin)
%NEWHOP Design a Hopfield recurrent network.
%
%  Hopfield networks perform a kind of pattern recall.  They are included
%  primarily for historical purposes.  For more robust pattern recognition
%  use <a href="matlab:doc patternnet">patternnet</a>.
%
%  <a href="matlab:doc newhop">newhop</a>(T) takes  an RxQ matrix of Q target vectors T with element
%  values of +1 or -1, and returns a new Hopfield recurrent neural
%  network with stable points at the vectors in T.
%
%  Here a Hopfield network with two three-element stable points is
%  designed and simulated.
%
%    T = [-1 -1 1; 1 -1 1]';
%    net = <a href="matlab:doc newhop">newhop</a>(T);
%    Ai = T;
%    [Y,Pf,Af] = net(2,[],Ai)
%    
%  To see if the network can correct a corrupted vector, run
%  the following code which simulates the Hopfield network for
%  five timesteps.  (Since Hopfield networks have no inputs,
%  the second argument to SIM is {Q TS} = [1 5] when using cell
%  array notation.)
%
%    Ai = {[-0.9; -0.8; 0.7]};
%    [Y,Pf,Af] = net({1 5},{},Ai);
%    Y{1}
%
%  If you run the above code Y{1} will equal T(:,1) if the
%  network has managed to convert the corrupted vector Ai to
%  the nearest target vector.
%
%  See also SIM, SATLINS.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.6.14 $ $Date: 2011/05/09 01:01:41 $

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
  info = nnfcnNetwork(mfilename,'Hopfield Network',fcnversion, ...
    [ ...
    nnetParamInfo('targets','Target Data','nntype.data',{1},...
    'Target output data.'), ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = create_network(param)

  % Format
  t = param.targets;
  if iscell(t), t = cell2mat(t); end
  
  % CHECKING
  if (~isa(t,'double')) || ~isreal(t) || isempty(t)
    error(message('nnet:NNData:TargetsNotRealNonEmpty'));
  end

  % DIMENSIONS
  [S,Q] = size(t);

  % NETWORK PARAMETERS
  [w,b] = solvehop2(t);

  % NETWORK ARCHITECTURE
  net = network(0,1,[1],[],[1],[1]);

  % RECURRENT LAYER
  net.layers{1}.size = S;
  net.layers{1}.transferFcn = 'satlins';
  net.b{1} = b;
  net.lw{1,1} = w;
  net.layerWeights{1,1}.delays = 1;
end

%==========================================================
function [w,b] = solvehop2(t)

  [S,Q] = size(t);
  Y = t(:,1:Q-1)-t(:,Q)*ones(1,Q-1);
  [U,SS,V] = svd(Y);
  K = rank(SS);

  TP = zeros(S,S);
  for k=1:K
    TP = TP + U(:,k)*U(:,k)';
  end

  TM = zeros(S,S);
  for k=K+1:S
    TM = TM + U(:,k)*U(:,k)';
    end

  tau = 10;
  Ttau = TP - tau*TM;
  Itau = t(:,Q) - Ttau*t(:,Q);

  h = 0.15;
  C1 = exp(h)-1;
  C2 = -(exp(-tau*h)-1)/tau;

  w = expm(h*Ttau);
  b = U * [  C1*eye(K)         zeros(K,S-K);
           zeros(S-K,K)  C2*eye(S-K)] * U' * Itau;
end
%==========================================================
