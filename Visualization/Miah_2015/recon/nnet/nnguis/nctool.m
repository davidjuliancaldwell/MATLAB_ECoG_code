function result = nctool(command,varargin)
%NCTool Neural network classification tool
%  Syntax
%    
%    nctool
%    nctool('close')
%    
%  Description
%    
%    NCTOOL launches the neural network clustering wizard and leads
%    the user through solving a clustering problem using a self-organizing map.
%    The map forms a compressed representation of the inputs space, reflecting
%    both the relative density of input vectors in that space, and a
%    two-dimension compressed representation of the input space topology.
%
%    NCTOOL('close') closes the window.

% Copyright 2007-2011 The MathWorks, Inc.

if (nargin==1) && ischar(command) && strcmp(command,'info')
  result = nnfcnWizard(mfilename,'Classification',7.0);
  return
end

if nargout > 0, result = []; end

persistent STATE;
if isempty(STATE)
  mlock
  STATE.tool = nnjava.tools('nctool');
end
  
try
  if (nargout > 0), result = []; end
  if nargin == 0, command = 'select'; end
  switch command

    case {'handle','tool'}
      if nargout > 0
        result = STATE.tool;
      end

    case 'select',
      launch(STATE.tool);
      if nargout > 0
        result = STATE.tool;
      end
      
    case {'hide','close'}
      if usejava('swing')
        STATE.tool.setVisible(false);
      end

    case 'state', result = STATE;

    case 'cacheData'
      data = varargin{1};
      inputName = data.get(0);
      sampleByColumn = varargin{2};
      STATE = cacheData(STATE,inputName,sampleByColumn);

    case 'createNetwork'
      varargin = nnmisc.defaultc(varargin,{20});
      s1 = varargin{1};
      STATE = createNetwork(STATE,s1);

    case 'trainNetwork'
      STATE = trainNetwork(STATE);
      result = nnjava.tools('vector');
      
      addElement(result,nnjava.tools('string',sprintf('%f',STATE.rand_seed)));
      addElement(result,nnjava.tools('string',STATE.net2.trainFcn));

    case 'viewTrainPlot'
      plotFunction = varargin{1};
      viewTrainPlot(STATE,plotFunction)
      
    case 'testNetwork'
      data = varargin{1};
      inputName = data.get(0);
      sampleByColumn = varargin{2};
      STATE=testNetwork(STATE,inputName,sampleByColumn);
      result = nnjava.tools('vector');
      
    case 'viewTestPlot'
      plotFunction = varargin{1};
      viewTestPlot(STATE,plotFunction)
      
    case 'exportToWorkspace'
      names = varargin{1};
      exportToWorkspace(STATE,names);
      
    case 'generateSimulinkBlock'
      generateSimulinkBlock(STATE);
      
    case 'generateNetworkDiagram'
      view(STATE.net2);

    otherwise
      nnerr.throw(['Unrecognized command: ' command]);
  end
catch me
  errmsg = me.message;
  errmsg(errmsg<32) = ',';
  errmsg = nnjava.tools('string',errmsg);
  result = nnjava.tools('error',errmsg);
end

%% Cache Data
function STATE = cacheData(STATE,inputName,sampleByColumn)

inputs = evalin('base',inputName);
inputs = tonndata(inputs,sampleByColumn);
inputs = [inputs{:}];

STATE.inputName = inputName;
STATE.sampleByColumn = sampleByColumn;
STATE.inputs = inputs;

%% Create Network
function STATE = createNetwork(STATE,s1)

net1 = selforgmap([s1 s1]);
STATE.net1 = net1;

%% Train Network

function STATE = trainNetwork(STATE)

% Data
P = STATE.inputs;

% Record random seed
if isfield(STATE,'fix_seed')
  STATE.rand_seed = STATE.fix_seed;
  rs = RandStream.getGlobalStream;
  rs.Seed = STATE.fix_seed;
else
  rs = RandStream.getGlobalStream;
  STATE.rand_seed = rs.Seed;
end

STATE.net1 = init(STATE.net1);

% Trained network
net2 = configure(STATE.net1,P);
net2 = train(net2,P);
Y = net2(P);

drawnow

% Update State
STATE.net2 = net2;
STATE.outputs = Y;


%%
function viewTrainPlot(STATE,plotFunction)

switch plotFunction
  
  case 'plotsomnd'
    plotsomnd(STATE.net2);

  case 'plotsomplanes'
    plotsomplanes(STATE.net2);
    
  case 'plotsomhits'
    plotsomhits(STATE.net2,STATE.inputs);
    
  case 'plotsompos'
    plotsompos(STATE.net2,STATE.inputs);
  
end
drawnow

%%
function STATE = testNetwork(STATE,inputName,sampleByColumn)

STATE.optionalTest.performance = -1;
STATE.optionalTest.regression = -1;

inputs = evalin('base',inputName);
inputs = tonndata(inputs,sampleByColumn);
inputs = [inputs{:}];

STATE.optionalTest.inputs = inputs;
STATE.optionalTest.inputName = inputName;

STATE.optionalTest.outputs = STATE.net2(inputs);

%%
function viewTestPlot(STATE,plotFunction)

switch plotFunction
  
  case 'plotsomnd'
    plotsomnd(STATE.net2);

  case 'plotsomplanes'
    plotsomplanes(STATE.net2);
    
  case 'plotsomhits'
    plotsomhits(STATE.net2,STATE.optionalTest.inputs);
    
  case 'plotsompos'
    plotsompos(STATE.net2,STATE.optionalTest.inputs);
  
end
drawnow

%%
function exportToWorkspace(STATE,names)

networkName = names{1};
outputName = names{2};
inputName = names{3};
structName = names{4};

if isempty(structName)
  if ~isempty(networkName),assignin('base',networkName,STATE.net2); end
  if ~isempty(outputName), assignin('base',outputName,STATE.outputs); end
  if ~isempty(inputName), assignin('base',inputName,STATE.inputs); end
else
  s = struct;
  if ~isempty(networkName), s.(networkName) = STATE.net2; end
  if ~isempty(outputName), s.(outputName) = STATE.outputs; end
  if ~isempty(inputName), s.(inputName) = STATE.inputs; end
  assignin('base',structName,s);
end

%%
function generateSimulinkBlock(STATE)

gensim(STATE.net2);
