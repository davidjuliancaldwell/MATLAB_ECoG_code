function out1 = selforgmap(varargin)
%SELFORGMAP Self-organizing map.
%
%  For an introduction use the Neural Clustering Tool <a href="matlab: doc nctool">nctool</a>.
%  Click <a href="matlab:nctool">here</a> to launch it.
%
%  Self-organizing maps learn to cluster data based on similarity,
%  topology, with a preference (but no guarantee) of assigning the same
%  number of instances to each class.
%
%  <a href="matlab:doc selforgmap">selforgmap</a>(dimensions,coverSteps,initNeighbor,topologyFcn,distanceFcn)
%  takes a row vector defining the size of an N-dimensional neuron layer,
%  the number of training steps for initial covering of the input space,
%  the initial neighborhood size, and topology and distance functions,
%  and returns a self-organizing map.
% 
% The input size is set to 0.  This size will automatically be configured
%  to match particular data by <a href="matlab:doc train">train</a>. Or the you can manually configure
%  inputs and outputs with <a href="matlab:doc configure">configure</a>.
%
%  Defaults are used if <a href="matlab:doc selforgmap">selforgmap</a> is called with fewer arguments.
%  The default arguments are ([8 8],100,3,'<a href="matlab:doc hextop">hextop</a>',<a href="matlab:doc linkdist">linkdist</a>').
%
%  Here a network is used to map a simple set of data.
%
%    x = <a href="matlab:doc simplecluster_dataset">simplecluster_dataset</a>;
%    net = <a href="matlab:doc selforgmap">selforgmap</a>([8 8]);
%    net = <a href="matlab:doc train">train</a>(net,x);
%    <a href="matlab:doc view">view</a>(net)
%    y = net(x);
%    classes = <a href="matlab:doc vec2ind">vec2ind</a>(y);
%
%  See also LVQNET, COMPETLAYER, SELFORGMAP, NCTOOL.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.10.6 $ $Date: 2011/05/09 01:01:48 $

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
  info = nnfcnNetwork(mfilename,'Self-Organizing Map',fcnversion, ...
    [ ...
    nnetParamInfo('dimensions','Dimensions','nntype.strict_pos_int_row',[8 8],...
    'Dimensions of the neural layer.'), ...
    nnetParamInfo('coverSteps','Covering Steps','nntype.pos_int_scalar',100,...
    'Number of steps for neighborhood to shrink to 1.'), ...
    nnetParamInfo('initNeighbor','Initial Neighborhood','nntype.pos_int_scalar',3,...
    'Initial neighborhood size.'), ...
    nnetParamInfo('topologyFcn','Topology Function','nntype.topology_fcn','hextop',...
    'Pattern of neuron positions in the layer.'), ...
    nnetParamInfo('distanceFcn','Distance Function','nntype.distance_fcn','linkdist',...
    'Function to measure distances between neurons.') ...
    ]);
end

function err = check_param(param)
 err = '';
end

function net = create_network(param)

  % Architecture
  net = network(1,1,0,1,0,1);

  % Simulation
  net.layers{1}.dimensions = param.dimensions;
  net.layers{1}.topologyFcn = param.topologyFcn;
  net.layers{1}.distanceFcn = param.distanceFcn;
  net.inputWeights{1,1}.weightFcn = 'negdist';
  net.layers{1}.transferFcn = 'compet';

  % Learning
  net.inputWeights{1,1}.learnFcn = 'learnsomb';
  net.inputWeights{1,1}.learnParam.init_neighborhood = param.initNeighbor;
  net.inputWeights{1,1}.learnParam.steps = param.coverSteps;

  % Adaption
  net.adaptFcn = 'adaptwb';

  % Training
  net.trainFcn = 'trainbu';
  net.trainParam.epochs = max(200,param.coverSteps * 2);

  % Initialization
  net.initFcn = 'initlay';
  net.layers{1}.initFcn = 'initwb';
  net.inputWeights{1,1}.initFcn = 'initsompc';

  % Plots
  net.plotFcns = ...
    {'plotsomtop','plotsomnc','plotsomnd','plotsomplanes','plotsomhits','plotsompos'};
end
