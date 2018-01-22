function result = nprtool(command,varargin)
%NPRTool Neural network pattern recognition tool
%
%  Syntax
%
%    nprtool
%    nprtool('close')
%
%  Description
%
%    NPRTOOL launches a neural network pattern recognition wizard and
%    leads the user through solving a pattern recognition
%    classification problem using a two-layer feed-forward network
%    with sigmoid output neurons.
%
%    NPRTOOL('close') closes the window.

% Copyright 2007-2011 The MathWorks, Inc.

if (nargin==1) && ischar(command) && strcmp(command,'info')
  result = nnfcnWizard(mfilename,'Pattern Recognition',7.0);
  return
end

if nargout > 0, result = []; end

persistent STATE;
if isempty(STATE)
  mlock
  STATE.tool = nnjava.tools('nprtool');
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
      STATE = cacheData(STATE,inputName,targetName,sampleByColumn);

    case 'countTargets'
      result = nnjava.tools('vector');
      numTargets = countTargets(STATE);
      addElement(result,nnjava.tools('integer',numTargets));
    
    case 'createNetwork'
      varargin = nnmisc.defaultc(varargin,{20});
      s1 = varargin{1};
      STATE = createNetwork(STATE,s1);

    case 'trainNetwork'
      varargin = nnmisc.defaultc(varargin,{20 20});
      percentValidate = varargin{1};
      percentTest = varargin{2};
      STATE = trainNetwork(STATE,percentValidate,percentTest);
      result = nnjava.tools('vector');
      addElement(result,nnjava.tools('double',STATE.info.train.performance));
      addElement(result,nnjava.tools('double',STATE.info.validation.performance));
      addElement(result,nnjava.tools('double',STATE.info.test.performance));
      addElement(result,nnjava.tools('double',STATE.info.train.confusion*100));
      addElement(result,nnjava.tools('double',STATE.info.validation.confusion*100));
      addElement(result,nnjava.tools('double',STATE.info.test.confusion*100));
      addElement(result,nnjava.tools('string',sprintf('%f',STATE.rand_seed)));
      
    case 'viewTrainPlot'
      plotFunction = varargin{1};
      viewTrainPlot(STATE,plotFunction)
      
    case 'testNetwork'
      data = varargin{1};
      inputName = data.get(0);
      targetName = data.get(1);
      sampleByColumn = varargin{2};
      STATE = testNetwork(STATE,inputName,targetName,sampleByColumn);
      result = nnjava.tools('vector');
      addElement(result,nnjava.tools('double',STATE.optionalTest.performance));
      addElement(result,nnjava.tools('double',STATE.optionalTest.confusion*100));

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
function STATE = cacheData(STATE,inputName,targetName,sampleByColumn)

inputs = evalin('base',inputName);
targets = evalin('base',targetName);
inputs = tonndata(inputs,sampleByColumn);
targets = tonndata(targets,sampleByColumn);
inputs = [inputs{:}];
targets = [targets{:}];

STATE.inputName = inputName;
STATE.targetName = targetName;
STATE.sampleByColumn = sampleByColumn;
STATE.inputs = inputs;
STATE.targets = targets;

%%
function numTargets = countTargets(STATE)

numTargets = nnfast.numsamples(STATE.targets);

%%
function STATE = createNetwork(STATE,s1)

net1 = patternnet(s1);
STATE.net1 = net1;

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

% Data
x = STATE.inputs;
t = STATE.targets;

% Data division parameters
STATE.net1.divideParam.trainRatio = (100-percentValidate-percentTest)/100;
STATE.net1.divideParam.valRatio = percentValidate/100;
STATE.net1.divideParam.testRatio = percentTest/100;

% Train network
net2 = configure(STATE.net1,x,t);
[net2,tr] = train(net2,x,t);

% Evaluate
y = net2(x);

tt = t .* tr.trainMask{1};
info.train.indices = tr.trainInd;
info.train.performance = perform(net2,tt,y);
info.train.confusion = confusion(tt,y);

tt = t .* tr.valMask{1};
info.validation.indices = tr.valInd;
info.validation.performance = perform(net2,tt,y);
info.validation.confusion = confusion(tt,y);

tt = t .* tr.testMask{1};
info.test.indices = tr.testInd;
info.test.performance = perform(net2,tt,y);
info.test.confusion = confusion(tt,y);

% Update State
STATE.info = info;
STATE.outputs = y;
STATE.errors = t-y;
STATE.net2 = net2;

%%
function viewTrainPlot(STATE,plotFunction)

switch plotFunction
  case 'plotconfusion'
    i1 = STATE.info.train.indices;
    t1 = STATE.targets(:,i1);
    y1 = STATE.outputs(:,i1);
    i2 = STATE.info.validation.indices;
    t2 = STATE.targets(:,i2);
    y2 = STATE.outputs(:,i2);
    i3 = STATE.info.test.indices;
    t3 = STATE.targets(:,i3);
    y3 = STATE.outputs(:,i3);
    t4 = [t1 t2 t3];
    y4 = [y1 y2 y3];
    plotconfusion(t1,y1,'Training',t2,y2,'Validation',t3,y3,'Test',t4,y4,'All');
    
  case 'plotroc'
    i1 = STATE.info.train.indices;
    t1 = STATE.targets(:,i1);
    y1 = STATE.outputs(:,i1);
    i2 = STATE.info.validation.indices;
    t2 = STATE.targets(:,i2);
    y2 = STATE.outputs(:,i2);
    i3 = STATE.info.test.indices;
    t3 = STATE.targets(:,i3);
    y3 = STATE.outputs(:,i3);
    t4 = [t1 t2 t3];
    y4 = [y1 y2 y3];
    plotroc(t1,y1,'Training',t2,y2,'Validation',t3,y3,'Test',t4,y4,'All');
end
drawnow

%%
function STATE = testNetwork(STATE,inputName,targetName,sampleByColumn)

STATE.optionalTest.performance = -1;
STATE.optionalTest.regression = -1;

inputs = evalin('base',inputName);
targets = evalin('base',targetName);
inputs = tonndata(inputs,sampleByColumn);
targets = tonndata(targets,sampleByColumn);
inputs = [inputs{:}];
targets = [targets{:}];

STATE.optionalTest.inputs = inputs;
STATE.optionalTest.inputName = inputName;
STATE.optionalTest.targets = targets;
STATE.optionalTest.targetName = targetName;

y = STATE.net2(inputs);
perf = perform(STATE.net2,targets,y);
c = confusion(targets,y);

% Update State
STATE.optionalTest.outputs = y;
STATE.optionalTest.performance = perf;
STATE.optionalTest.confusion = c;

%%
function viewTestPlot(STATE,plotFunction)

switch plotFunction
  case 'plotconfusion'
    plotconfusion(STATE.optionalTest.targets,STATE.optionalTest.outputs);
    
  case 'plotroc'
    plotroc(STATE.optionalTest.targets,STATE.optionalTest.outputs)
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
  if ~isempty(outputName), assignin('base',outputName,STATE.outputs); end
  if ~isempty(errorName), assignin('base',errorName,STATE.errors); end
  if ~isempty(inputName), assignin('base',inputName,STATE.inputs); end
  if ~isempty(targetName), assignin('base',targetName,STATE.targets); end
else
  s = struct;
  if ~isempty(networkName), s.(networkName) = STATE.net2; end
  if ~isempty(perfName), s.(perfName) = STATE.info; end
  if ~isempty(outputName), s.(outputName) = STATE.outputs; end
  if ~isempty(errorName), s.(errorName) = STATE.errors; end
  if ~isempty(inputName), s.(inputName) = STATE.inputs; end
  if ~isempty(targetName), s.(targetName) = STATE.targets; end
  assignin('base',structName,s);
end

%%
function generateSimulinkBlock(STATE)

gensim(STATE.net2);
