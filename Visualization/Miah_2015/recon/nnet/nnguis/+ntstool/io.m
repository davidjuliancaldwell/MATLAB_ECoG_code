function result = io(command,varargin)
%NFTool Neural Network Time Series Tool - Input Output
%
%  Syntax
%    
%    ntstool
%    ntstool('close')
%    
%  Description
%    
%    NTSTOOL launches the neural network time series wizard and leads
%    the user through solving a fitting problem using a two-layer
%    feed-forward network.
%
%    NFTOOL('close') closes the window.

% Copyright 2007-2011 The MathWorks, Inc.

if (nargin==1) && ischar(command) && strcmp(command,'info')
  result = nnfcnWizard(mfilename,'Time Series',7.0);
  return
end

if nargout > 0, result = []; end

persistent STATE;
if isempty(STATE)
  mlock
  STATE.tool = nnjava.tools('ntstool');
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
      targetName = data.get(1);
      sampleByColumn = varargin{2};
      timeInCell = varargin{3};
      STATE = cacheData(STATE,inputName,targetName,sampleByColumn,timeInCell);
    
    case 'createNetwork'
      varargin = nnmisc.defaultc(varargin,{20 2});
      layerSize = varargin{1};
      delaySize = varargin{2};
      STATE = createNetwork(STATE,layerSize,delaySize);
      
    case 'countTargets'
      result = nnjava.tools('vector');
      numTargets = countTargets(STATE);
      addElement(result,nnjava.tools('integer',numTargets));
    
    case 'trainNetwork'
      varargin = nnmisc.defaultc(varargin,{20 20});
      percentValidate = varargin{1};
      percentTest = varargin{2};
      STATE = trainNetwork(STATE,percentValidate,percentTest);
      result = nnjava.tools('vector');
      addElement(result,nnjava.tools('double',STATE.info.train.performance));
      addElement(result,nnjava.tools('double',STATE.info.validation.performance));
      addElement(result,nnjava.tools('double',STATE.info.test.performance));
      addElement(result,nnjava.tools('double',STATE.info.train.regression));
      addElement(result,nnjava.tools('double',STATE.info.validation.regression));
      addElement(result,nnjava.tools('double',STATE.info.test.regression));
      addElement(result,nnjava.tools('string',sprintf('%f',STATE.rand_seed)));
      addElement(result,nnjava.tools('string',STATE.net2.trainFcn));
    
    case 'viewTrainPlot'
      plotFunction = varargin{1};
      viewTrainPlot(STATE,plotFunction)
    
    case 'testNetwork'
      data = varargin{1};
      inputName = data.get(0);
      targetName = data.get(1);
      sampleByColumn = varargin{2};
      timeInCell = varargin{3};
      STATE = testNetwork(STATE,inputName,targetName,sampleByColumn,timeInCell);
      result = nnjava.tools('vector');
      addElement(result,nnjava.tools('double',STATE.optionalTest.performance));
      addElement(result,nnjava.tools('double',STATE.optionalTest.regression));
    
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
      nnerr.throw('Args',['Unrecognized command: ' command]);
  end
catch me
  errmsg = me.message;
  errmsg(errmsg<32) = ',';
  errmsg = nnjava.tools('string',errmsg);
  result = nnjava.tools('error',errmsg);
end

%%
function STATE = cacheData(STATE,inputName,targetName,sampleByColumn,timeInCell)

inputs = evalin('base',inputName);
targets = evalin('base',targetName);
inputs = tonndata(inputs,sampleByColumn,timeInCell);
targets = tonndata(targets,sampleByColumn,timeInCell);

STATE.inputs = inputs;
STATE.inputName = inputName;
STATE.targets = targets;
STATE.targetName = targetName;

STATE.sampleByColumn = sampleByColumn;
STATE.timeInCell = timeInCell;

%%
function STATE = createNetwork(STATE,layerSize,numDelayLines)

% Create network
inputDelays = 1:numDelayLines;
net1 = timedelaynet(inputDelays,layerSize);

% Save state
STATE.layerSize = layerSize;
STATE.delaySize = numDelayLines;
STATE.net1 = net1;

%%
function numTargets = countTargets(STATE);

[x,xi,ai,t] = preparets(STATE.net1,STATE.inputs,STATE.targets);
numTargets = numfinite(t);

%%
function STATE = trainNetwork(STATE,percentValidate,percentTest)

% Record random seed
if isfield(STATE,'fix_seed')
  STATE.rand_seed = STATE.fix_seed;
  rs = RandStream.getGlobalStream;
  rs.Seed = STATE.fix_seed;
else
  rs = RandStream.getGlobalStream;
  STATE.rand_seed = rs.Seed;
end

% Data Division
STATE.net1.divideParam.trainRatio = (100-percentValidate-percentTest)/100;
STATE.net1.divideParam.valRatio = percentValidate/100;
STATE.net1.divideParam.testRatio = percentTest/100;

% Train
[x,xi,ai,t] = preparets(STATE.net1,STATE.inputs,STATE.targets);
net2 = configure(STATE.net1,[x xi],t);
[net2,tr] = train(net2,x,t,xi,ai);
drawnow

% Evaluate
y = net2(x,xi,ai);
e = gsubtract(t,y);

tt = gmultiply(t,tr.trainMask);
info.train.performance = perform(net2,tt,y);
info.train.regression = regression(tt,y,'one');
info.train.indices = tr.trainInd;
info.train.mask = tr.trainMask;

tt = gmultiply(t,tr.valMask);
info.validation.performance = perform(net2,tt,y);
info.validation.regression = regression(tt,y,'one');
info.validation.indices = tr.valInd;
info.validation.mask = tr.valMask;

tt = gmultiply(t,tr.testMask);
info.test.performance = perform(net2,tt,y);
info.test.regression = regression(tt,y,'one');
info.test.indices = tr.testInd;
info.test.mask = tr.testMask;

% Save State
STATE.net2 = net2;
STATE.x = x;
STATE.xi = xi;
STATE.t = t;
STATE.y = y;
STATE.e = e;
STATE.info = info;

%%
function viewTrainPlot(STATE,plotFunction)

switch plotFunction
  case 'plotresponse'
    y = STATE.y;
    t = STATE.t;
    t1 = gmultiply(t,STATE.info.train.mask);
    t2 = gmultiply(t,STATE.info.validation.mask);
    t3 = gmultiply(t,STATE.info.test.mask);
    plotresponse(t1,'Training',t2,'Validation',t3,'Test',y);
  case 'ploterrhist'
    y = STATE.y;
    t = STATE.t;
    e1 = gsubtract(gmultiply(t,STATE.info.train.mask),y);
    e2 = gsubtract(gmultiply(t,STATE.info.validation.mask),y);
    e3 = gsubtract(gmultiply(t,STATE.info.test.mask),y);
    ploterrhist(e1,'Training',e2,'Validation',e3,'Test','T-Y');
  case 'ploterrcorr'
    ploterrcorr(STATE.e)
  case 'plotinerrcorr'
    plotinerrcorr(STATE.x,STATE.e,'T-Y');
end
drawnow

%%
function STATE = testNetwork(STATE,inputName,targetName,sampleByColumn,timeInCell)

% In case of errors
STATE.optionalTest.performance = -1;
STATE.optionalTest.regression = -1;

% Get data
inputs = evalin('base',inputName);
targets = evalin('base',targetName);
inputs = tonndata(inputs,sampleByColumn,timeInCell);
targets = tonndata(targets,sampleByColumn,timeInCell);

% Evaluate
[x,xi,ai,t] = preparets(STATE.net2,inputs,targets);
y = STATE.net2(x,xi,ai);
e = gsubtract(t,y);
perf = perform(STATE.net2,t,y);
r = mean(regression(t,y));

% Save state
STATE.optionalTest.inputName = inputName;
STATE.optionalTest.targetName = targetName;
STATE.optionalTest.x = x;
STATE.optionalTest.xi = xi;
STATE.optionalTest.ai = ai;
STATE.optionalTest.t = t;
STATE.optionalTest.y = y;
STATE.optionalTest.e = e;
STATE.optionalTest.performance = perf;
STATE.optionalTest.regression = r;

%%
function viewTestPlot(STATE,plotFunction)

switch plotFunction
  case 'plotresponse'
    plotresponse(STATE.optionalTest.t,STATE.optionalTest.y);
  case 'ploterrcorr'
    ploterrcorr(STATE.optionalTest.e)
  case 'ploterrhist'
    ploterrhist(STATE.optionalTest.e,'T-Y')
  case 'plotinerrcorr'
    plotinerrcorr(STATE.optionalTest.x,STATE.optionalTest.e,'T-Y');
end
drawnow

%%
function exportToWorkspace(STATE,names)

networkName = names{1};
perfName = names{2};
outputName = names{3};
errorName = names{4};
inputName = names{5};
targetName = names{6};
structName = names{7};
if isempty(structName)
  if ~isempty(networkName),assignin('base',networkName,STATE.net2); end
  if ~isempty(perfName), assignin('base',perfName,STATE.info); end
  if ~isempty(outputName), assignin('base',outputName,STATE.y); end
  if ~isempty(errorName), assignin('base',errorName,STATE.e); end
  if ~isempty(inputName), assignin('base',inputName,STATE.inputs); end
  if ~isempty(targetName), assignin('base',targetName,STATE.targets); end
else
  s = struct;
  if ~isempty(networkName), s.(networkName) = STATE.net2; end
  if ~isempty(perfName), s.(perfName) = STATE.info; end
  if ~isempty(outputName), s.(outputName) = STATE.y; end
  if ~isempty(errorName), s.(errorName) = STATE.e; end
  if ~isempty(inputName), s.(inputName) = STATE.inputs; end
  if ~isempty(targetName), s.(targetName) = STATE.targets; end
  assignin('base',structName,s);
end

%%
function generateSimulinkBlock(STATE)

gensim(STATE.net2);
