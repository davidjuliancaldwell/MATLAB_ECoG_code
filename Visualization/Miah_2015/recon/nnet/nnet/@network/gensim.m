function [sysName,netName] = gensim(net,varargin)
%GENSIM Generate a Simulink block diagram of a neural network.
%
%  [SYSNAME,NETNAME] = <a href="matlab:doc gensim">gensim</a>(NET) takes a neural network NET, generates
%  a Simulink system containing a block which implements NET, and returns
%  the name of the system and network block.
%
%  If the network has delays its sample time is determined by the network
%  property NET.<a href="matlab:doc nnproperty.net_sampleTime">sampleTime</a>, otherwise the sample time will be -1.
%
%  Optional pairs of parameter/value arguments may be added to the argument
%  list as <a href="matlab:doc gensim">gensim</a>(NET,'param1',value1,'param2',value2,...).  The parameters
%  and value definitions are:
%
%    'Name' - A string to be the new system's name.
%
%    'SampleTime' - The value may be -1 or any integer greater or equal
%    to 1.  This overrides the default sample time.
%
%    'InputMode' - The value may be 'none', 'port', 'workspace', or the
%    default, 'constant'.  This indicates the kind of input block generated.
%   
%    'OutputMode' - The value may be 'none', 'display', 'port', 'workspace',
%    or the default, 'scope'.
%
%    'SolverMode' - This can be 'default' which leaves the generated system
%    with the default Simulink solver settings, or 'discrete' which sets
%    the solver mode to discrete with the steps equal to the sample time.
%
%  Here a NARX network is designed. The NARX network has a standard input
%  and an open loop feedback output to an associated feedback input.
%
%    [x,t] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%    net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%    <a href="matlab:doc view">view</a>(net)
%    [xs,xi,ai,ts] = <a href="matlab:doc preparets">preparets</a>(net,x,{},t);
%    net = <a href="matlab:doc train">train</a>(net,xs,ts,xi,ai);
%    y = net(xs,xi,ai);
%
%  Now the network is converted to closed loop, and the data is reformatted
%  to simulate the network's closed loop response.
%
%    net = <a href="matlab:doc closeloop">closeloop</a>(net);
%    <a href="matlab:doc view">view</a>(net)
%    [xs,xi,ai] = <a href="matlab:doc preparets">preparets</a>(net,x,{},t);
%    y = net(xs,xi,ai);
%
%  Here the network is converted to a Simulink system with workspace
%  input and output ports. Its delay states are initialized, inputs X1
%  defined in the workspace, and it is ready to be simulated in Simulink.
%
%    [sysName,netName] = <a href="matlab:doc gensim">gensim</a>(net,'InputMode','Workspace',...
%      'OutputMode','WorkSpace','SolverMode','Discrete');
%    <a href="matlab:doc setsiminit">setsiminit</a>(sysName,netName,net,xi,ai,1);
%    x1 = <a href="matlab:doc nndata2sim">nndata2sim</a>(x,1,1);
%
%  Or the system can be simulated from the command line.
%
%    TS = <a href="matlab:doc numtimesteps">numtimesteps</a>(x);
%    set_param(getActiveConfigSet(sysName),...
%     'StartTime','0','StopTime',num2str(TS-1),'ReturnWorkspaceOutputs','on');
%    simOut = sim(sysName)
%    ysim = <a href="matlab:doc sim2nndata">sim2nndata</a>(simOut.find('y1'))
%
%  See also SETSIMINIT, NNDATA2SIM, SIM2NNDATA, VIEW.

%  Mark Beale, 11-31-97
%  Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.11.4.13 $ $Date: 2012/04/20 19:11:49 $

% Check Simulink Availability
if ~nnDependency.simulinkAvailable
  error(message('nnet:Simulink:NotAvailable'));
end

% Checks
if nargin < 1, error(message('nnet:Args:NotEnough')); end

% NNET 6 Compatibility
if length(varargin) == 1
  varargin = {'sampletime',varargin{1}};
end

% Default Parameters
sysName = '';
inputMode = 'constant';
outputMode = 'scope';
configMode = 'default';
sampleTime = net.sampleTime;
if all([net.numInputDelays net.numLayerDelays net.numFeedbackDelays] == 0)
  sampleTime = -1;
end

% Parameters
numPairs = floor(length(varargin)/2);
if length(varargin) ~= numPairs * 2
  error(message('nnet:Args:BadPairs'));
end
for i=1:numPairs
  pname = varargin{i*2-1};
  pvalue = varargin{i*2};
  err = nntype.string('check',pname);
  if ~isempty(err), nnerr.throw(nnerr.value(err,['Input argument ' num2str(i*2-1)])); end
  switch lower(pname)
    case 'name'
      sysName = nntype.string('format',pvalue,'Name');
    case 'sampletime'
      nntype.num_scalar('check',pvalue,'Sampling time');
      if (pvalue <= 0) && (pvalue ~= -1),
        error(message('nnet:gensim:BadStaticSampleTime'))
      end
      if (pvalue == -1) && ((net.numInputDelays + net.numLayerDelays + net.numFeedbackDelays) > 0)
        error(message('nnet:gensim:BadDynamicSampleTime'))
      end
      sampleTime = pvalue;
    case 'inputmode'
      inputMode = nntype.simulink_input_mode('format',pvalue,'Input mode');
    case 'outputmode'
      outputMode = nntype.simulink_output_mode('format',pvalue,'Input mode');
    case 'solvermode'
      configMode = nntype.simulink_config_mode('format',pvalue,'Solver mode');
    otherwise, error(message('nnet:NNParam:Unrecognized'));
  end
end

% Delete zero-sized inputs, layers and outputs
[net,PI,PL,PO,change] = prune(net);
if change
  warning('nnet:gensim:pruned',nnwarning.net_pruned_for_simulink)
end
if ~isempty(PI)
  for i=PI
    disp([nnlink.fcn2ulink('gensim') ': Input ' num2str(i) ' has been pruned.']);
  end
end
if ~isempty(PL)
  for i=PL
    disp([nnlink.fcn2ulink('gensim') ': Layer ' num2str(i) ' has been pruned.']);
  end
end
if ~isempty(PO)
  for i=PO
    disp([nnlink.fcn2ulink('gensim') ': Output ' num2str(i) ' has been pruned.']);
  end
end
if (net.numOutputs == 0)
  disp([nnlink.fcn2ulink('gensim') ': Generated Simulink neural network has no outputs.']);
end
net = struct(net);

% Neural Network Toolbox Simulink Block Library
neural;

% Position
maxSignal = max(net.numInputs,net.numOutputs);
centerY = 20 + max(maxSignal*90-40,140)/2;
inputY = centerY - 25 - (net.numInputs-1)*45 + 5;
outputY = centerY - 25 - (net.numOutputs-1)*45 + 5;
networkY = centerY - 70;

fixes = [0 -1 -1 -1 0 0 1 1 1 1 2];
fixY = 5*fixes(min(maxSignal,10)+1);
inputY = inputY + fixY;
outputY = outputY + fixY;

% New System
if isempty(sysName)
  sysName = get_param(new_system,'name');
else
  new_system(sysName);
end
open_system(sysName);
set_param(sysName,'location',[50 50 500 min(centerY*2+70,600)]);

% Inputs
if (sampleTime == -1)
  inputSampleTime = 1;
else
  inputSampleTime = sampleTime;
end
inputNames = cell(1,net.numInputs);
for i=1:net.numInputs
  variableName = ['x' num2str(i)];
  inputName = net.inputs{i}.name;
  if isempty(inputName)
    if net.numInputs == 1
      inputName = 'Input';
    else
      inputName = variableName;
    end
  end
  inputName = uniquename(inputName,inputNames(1:(i-1)));
  inputNames{i} = inputName;
  posY = (i-1)*90+inputY;
  position = [30 posY 80 posY+50];
  if (net.inputs{1}.size == 0)
    if ~strcmp(inputMode,'none')
      add_block('built-in/SubSystem',[sysName '/' variableName],...
        'maskdisplay',[signalMask 'disp(''[ ]'')'],'MaskIconFrame','off',...
        'position',position);
    end
  else
    switch inputMode
      case 'none'
        % no input block
      case 'constant'
         add_block('built-in/Constant',[sysName '/' variableName],...
        'value',mat2str(rand(net.inputs{i}.size,1),2),...
        'sampletime',num2str(inputSampleTime),...
        'maskdisplay',[signalMask 'disp(''Constant'');'],'MaskIconFrame','off',...
        'position',position)
      case 'port'
        add_block('built-in/Inport',[sysName '/' variableName],...
        'PortDimensions',num2str(net.inputs{i}.size),...
        'maskdisplay',[signalMask 'disp(''Inport'');'],'MaskIconFrame','off',...
        'position',position)
      case 'sequence',
        add_block('built-in/Inport',[sysName '/' variableName],...
        'PortDimensions',num2str(net.inputs{i}.size),...
        'maskdisplay',[signalMask 'disp(''Inport'');'],'MaskIconFrame','off',...
        'position',position)
      case 'workspace',
         add_block('built-in/From Workspace',[sysName '/' variableName],...
        'variablename',variableName,...
        'sampletime',num2str(inputSampleTime),...
        'maskdisplay',[signalMask 'disp(''WS =>'')'],'MaskIconFrame','off',...
        'position',position)
    end
  end
end

% Outputs
outputNames = cell(1,net.numOutputs);
for i=1:net.numOutputs
  variableName = ['y' num2str(i)];
  ii = find(cumsum(net.outputConnect)==i,1);
  outputName = net.outputs{ii}.name;
  if isempty(outputName)
    if net.numOutputs == 1
      outputName = 'Output';
    else
      outputName = variableName;
    end
  end
  outputName = uniquename(outputName,[inputNames outputNames(1:(i-1))]);
  outputNames{i} = outputName;
  posY = (i-1)*90+outputY;
  position = [370 posY 370+50 posY+50];
  switch outputMode
    case 'none'
      % no output block
    case 'display'
      position(3) = position(3) + 40;
      add_block('built-in/Display',[sysName '/' variableName],...
      'maskdisplay',[signalMask 'disp(''Display'');'],'MaskIconFrame','off',...
      'position',position)
    case 'port'
      add_block('built-in/Outport',[sysName '/' variableName],...
      'PortDimensions',num2str(net.outputs{ii}.size),...
      'maskdisplay',[signalMask 'disp(''Outport'');'],'MaskIconFrame','off',...
      'position',position)
    case 'scope'
      add_block('built-in/Scope',[sysName '/' variableName],...
      'maskdisplay',[signalMask 'plot([0.15 0.85 0.85 0.15 0.15],[0.5 0.5 0.85 0.85 0.5]);'],'MaskIconFrame','off',...
      'position',position)
    case 'workspace'
      add_block('built-in/To Workspace',[sysName '/' variableName],...
      'variablename',variableName,...
      'sampletime','-1',...
      'maskdisplay',[signalMask 'disp(''=> WS'');'],'MaskIconFrame','off',...
      'position',position); 
  end
end

% Network
netName = net.name;
if isempty(netName)
  netName = 'Neural Network';
end
genNetwork(net,networkY,netName,sysName,num2str(sampleTime),inputNames,outputNames)

% Connect Inputs to Network
if ~strcmp(inputMode,'none')
  for i=1:net.numInputs
    if net.inputs{i}.size > 0
      add_line(sysName,['x' num2str(i) '/1'],[netName '/' num2str(i)])
    end
  end
end

% Connect Outputs to Network
if ~strcmp(outputMode,'none')
  for i=1:net.numOutputs
    ii = find(cumsum(net.outputConnect)==i,1);
    if net.outputs{ii}.size > 0
      add_line(sysName,[netName '/' num2str(i)],['y' num2str(i) '/1'])
    end
  end
end

% Configuration
if strcmp(configMode,'discrete')
  cs = getActiveConfigSet(sysName);
  set_param(cs,'SolverType','Fixed-Step','Solver','FixedStepDiscrete',...
    'FixedStep',num2str(max(1,sampleTime)));
end

%======================================================================
function genNetwork(net,networkY,netName,sysName,st,inputNames,outputNames)

% Network System
netNameL = [sysName '/' netName];

mask = [transformMask; {'fprintf(''NNET'');'}];
for i=1:net.numInputs
  mask = [mask; {['port_label(''input'',' num2str(i) ','' ' inputNames{i} ''');']}];
end
for i=1:net.numOutputs
  mask = [mask; {['port_label(''output'',' num2str(i) ',''' outputNames{i} ' '');']}];
end
mask = [mask{:}];

add_block('built-in/SubSystem',netNameL);
set_param(netNameL, ...
  'position',[160 networkY 160+140 networkY+140]);
  
% Layer2Layer
Layer2LayerInd = find(sum(net.layerConnect,1));
numLayer2Layers = length(Layer2LayerInd);

% Network Block Names
processInputNames = cell(1,net.numInputs);
processedInputNames = cell(1,net.numInputs);
processOutputNames = cell(1,net.numOutputs);
fromNames = cell(1,net.numLayers);
toNames = cell(1,net.numLayers);
layerNames = cell(1,net.numLayers);
for i=1:net.numInputs, processInputNames{i} = sprintf('Process Input %g',i); end
for i=1:net.numInputs, processedInputNames{i} = sprintf('p{%g}',i); end
for i=1:net.numOutputs, processOutputNames{i} = sprintf('Process Output %g',i); end
for i=1:net.numLayers, fromNames{i} = sprintf(' a{%g} ',i); end
for i=1:net.numLayers, toNames{i} = sprintf('a{%g}',i); end
for i=1:net.numLayers, layerNames{i} = sprintf('Layer %g',i); end

% Network Blocks
for i=1:net.numInputs
  genNetworkInput(net,i,i,inputNames{i},processInputNames{i},processedInputNames{i},netNameL,st);
end
for i=1:net.numOutputs
  genNetworkOutput(net,i,i+1+numLayer2Layers,processOutputNames{i},outputNames{i},netNameL,st);
end
for k=1:numLayer2Layers
  i = Layer2LayerInd(k);
  genNetworkFrom(net,i,k+net.numInputs+1,fromNames{i},netNameL);
end
for k=1:numLayer2Layers
  i = Layer2LayerInd(k);
  genNetworkTo(net,i,k,toNames{i},netNameL);
end
layerPos = 40;
for i=1:net.numLayers
  layerPos = genNetworkLayer(net,i,layerNames{i},netNameL,processedInputNames,toNames,fromNames,layerPos,st);
end

% Network Block Connections
for i=1:net.numLayers
  inputInd = find(net.inputConnect(i,:));
  numInputs = length(inputInd);
  for j=1:numInputs
    add_line(netNameL,[processInputNames{inputInd(j)} '/1'],[layerNames{i} '/' num2str(j)])
  end
end
for k=1:numLayer2Layers
  j = Layer2LayerInd(k);
  add_line(netNameL,[layerNames{j} '/1'],[toNames{j} '/1'])
  layerInd = find(net.layerConnect(:,j)');
  numLayers = length(layerInd);
  for m=1:numLayers
    i = layerInd(m);
    numInputs = length(find(net.inputConnect(i,:)));
    x = sum(net.layerConnect(i,1:j));
    add_line(netNameL,[fromNames{j} '/1'],[layerNames{i} '/' num2str(numInputs+x)])
  end
end
outputInd = find(net.outputConnect);
numOutputs = length(outputInd);
for i=1:numOutputs
  add_line(netNameL,[layerNames{outputInd(i)} '/1'],[processOutputNames{i} '/1'])
end

numVar = 0;
maskVariables = '';
maskValues = {};
maskPromptString = '';
inputDelays = nn.input_delays(net);
layerDelays = nn.layer_delays(net);
for i=1:net.numInputs
  for k=1:inputDelays(i)
    numVar = numVar + 1;
    maskVariables = [maskVariables ...
      'pi_input_' num2str(i) '_delayed_' num2str(k) '=@' num2str(numVar) ';'];
    maskValues = [maskValues { mat2str(zeros(net.inputs{i}.processedSize,1)) }];
    maskPromptString = [maskPromptString ...
      'Preprocessed initial input ' num2str(i) ' state at timestep ' num2str(1-k) '.|'];
  end
end
for i = 1:net.numLayers
  for k=1:layerDelays(i)
    numVar = numVar + 1;
    maskVariables = [maskVariables ...
      'ai_layer_' num2str(i) '_delayed_' num2str(k) '=@' num2str(numVar) ';'];
    maskValues = [maskValues { mat2str(zeros(net.layers{i}.size,1)) }];
    maskPromptString = [maskPromptString ...
      'Initial layer ' num2str(i) ' state at timestep ' num2str(1-k) '.|'];
  end
end

set_param(netNameL, ...
  'MaskDisplay',mask,'MaskIconFrame','off')

if isempty(net.name)
  maskDescription = 'Neural Network';
else
  maskDescription = net.name;
end
set_param([sysName,'/',netName],'mask','on',...
  'MaskDescription',maskDescription,...
  'MaskVariables',maskVariables,...
  'MaskValues',maskValues,...
  'MaskPromptString',maskPromptString);

%======================================================================
function genNetworkInput(net,inputIndex,pos,inputName,processInputName,...
  processedInputName,netNameL,sampleTime)

  y = pos*40;
  
  add_block( ...
    'built-in/Inport',[netNameL '/' inputName],...
    'port',num2str(inputIndex), ...
    'position',[40 y 60 y+20],...
    'portwidth',num2str(net.inputs{inputIndex}.size),...
    'sampletime',sampleTime,...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off');

  fullProcessName = [netNameL '/' processInputName];
  add_block('built-in/SubSystem',fullProcessName,...
    'position',[100 y 120 y+20],...
    'maskdisplay',transformMask,...
    'MaskIconFrame','off');
 
  unprocessedSize = net.inputs{inputIndex}.size;
  processedSize = net.inputs{inputIndex}.processedSize;

  add_block( ...
    'built-in/Inport',[fullProcessName '/x'],...
    'port','1', ...
    'portwidth',num2str(unprocessedSize),...
    'sampletime',num2str(sampleTime),...
    'position',[20 30 60 70],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off');
  lastBlock = 'x';

  processFcns = net.inputs{inputIndex}.processFcns;
  processSettings = net.inputs{inputIndex}.processSettings;
  pos = 120;
  for i=1:length(processFcns)
    pf = lower(processFcns{i});
    ps = processSettings{i};
    sysName = [fullProcessName '/' pf];
    add_block(...
      ['neural/Processing Functions/' pf],sysName, ...
      'position',[pos 30 (pos+40) 70],...
      'BackgroundColor','lightblue');
    param = feval(pf,'simulinkParameters',ps);
    for j=1:size(param,1)
      set_param(sysName,param{j,1},param{j,2});
    end
    pos = pos + 100;
    add_line(fullProcessName,[lastBlock '/1'],[pf '/1']);
    lastBlock = pf;
  end

  add_block( ...
    'built-in/Outport',[fullProcessName '/p'],...
    'port','1',...
    'portwidth',num2str(processedSize),...
    'sampletime',num2str(sampleTime),...
    'position',[pos 30 pos+40 70],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off');
  add_line(fullProcessName,[lastBlock '/1'],['p/1']);
  
  add_line(netNameL,[inputName '/1'],[processInputName '/1']);

%======================================================================
function genNetworkOutput(net,outputIndex,pos,processOutputName,...
  outputName,netNameL,sampleTime)

  outputInd = find(net.outputConnect);
  siz = net.outputs{outputInd(outputIndex)}.size;
  y = pos*40;
  outputNameL = [netNameL '/' outputName];
  add_block(...
    'built-in/Outport',outputNameL,...
    'port',sprintf('%g',outputIndex), ...
    'position',[380 y 400 y+20],...
    'InitialOutput',mat2str(zeros(siz,1)),...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off');
  
  fullProcessName = [netNameL '/' processOutputName];
  add_block('built-in/SubSystem',fullProcessName,...
    'position',[320 y 340 y+20],...
    'maskdisplay',transformMask,...
    'MaskIconFrame','off');

  unprocessedSize = net.outputs{outputInd(outputIndex)}.size;
  processedSize = net.outputs{outputInd(outputIndex)}.processedSize;

  add_block( ...
    'built-in/Inport',[fullProcessName '/a'],...
    'port','1', ...
    'portwidth',num2str(processedSize),...
    'sampletime',num2str(sampleTime),...
    'position',[20 30 60 70],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off');
  lastBlock = 'a';

  processFcns = net.outputs{outputInd(outputIndex)}.processFcns;
  processSettings = net.outputs{outputInd(outputIndex)}.processSettings;
  pos = 120;
  for i=length(processFcns):-1:1
    pf = lower(processFcns{i});
    ps = processSettings{i};
    pfr = [pf '_reverse'];
    sysName = [fullProcessName '/' pfr];
    add_block(...
      ['neural/Processing Functions/' pfr],sysName, ...
      'position',[pos 30 (pos+40) 70],...
      'BackgroundColor','lightblue');
    param = feval(pf,'simulinkParametersReverse',ps);
    for j=1:size(param,1)
      set_param(sysName,param{j,1},param{j,2});
    end
    pos = pos + 100;
    add_line(fullProcessName,[lastBlock '/1'],[pfr '/1']);
    lastBlock = pfr;
  end

  add_block( ...
    'built-in/Outport',[fullProcessName '/y'],...
    'port','1',...
    'portwidth',num2str(unprocessedSize),...
    'sampletime',num2str(sampleTime),...
    'position',[pos 30 pos+40 70],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off');
  add_line(fullProcessName,[lastBlock '/1'],['y/1']);
  
  add_line(netNameL,[processOutputName '/1'],[outputName '/1']);
  
%======================================================================
function genNetworkFrom(net,i,pos,fromName,netNameL)

  y = pos*40;
  fromNameL = [netNameL '/' fromName];
  add_block(...
    'built-in/From',fromNameL,...
    'gototag',sprintf('feedback%g',i), ...
    'position',[40 y 60 y+20],...
    'maskdisplay','plot(cos(0:.1:2*pi),sin(0:.1:2*pi))',...
    'MaskIconFrame','off',...
    'ForegroundColor','black')

%======================================================================
function genNetworkTo(net,i,pos,toName,netNameL)

  y = pos*40;
  toNameL = [netNameL '/' toName];
  add_block('built-in/Goto',toNameL,...
    'gototag',sprintf('feedback%g',i), ...
  'position',[380 y 400 y+20],...
  'maskdisplay','plot(cos(0:.1:2*pi),sin(0:.1:2*pi))',...
  'MaskIconFrame','off',...
  'ForegroundColor','black')

%======================================================================
function layerPos = genNetworkLayer(net,i,layerName,netNameL,inputName,toName,fromName,layerPos,st)

  % Useful constants
  inputInd = find(net.inputConnect(i,:));
  numInputs = length(inputInd);
  layerInd = find(net.layerConnect(i,:));
  numLayers = length(layerInd);
  hasBias = net.biasConnect(i);
  y = (numInputs+numLayers+hasBias)/2 * 60 + 30;
  dy = max(10,(numInputs+numLayers+hasBias)*5);

  % Layer System
  layerNameL = [netNameL '/' layerName];
  layerHeight = max(1,numInputs+numLayers)*20;
  add_block('built-in/SubSystem',layerNameL)
  set_param(layerNameL,...
    'position',[190 layerPos 250 layerPos+layerHeight],...
    'maskdisplay',transformMask,...
    'MaskIconFrame','off');
  
  % increase LayerPos
  layerPos = layerPos + layerHeight + 20;

  % Layer Block Names
  outputName = sprintf('a{%g}',i);
  transferName = net.layers{i}.transferFcn;
  netInputName = net.layers{i}.netInputFcn;
  for k=1:numInputs
    j = inputInd(k);
    IWName{k} = sprintf('IW{%g,%g}',i,j);
    IDName{k} = sprintf('Delays %g',k);
    PName{k} = inputName{j};
  end
  for k=1:numLayers
    j = layerInd(k);
    LWName{k} = sprintf('LW{%g,%g}',i,j);
    LDName{k} = sprintf('Delays %g',k+numInputs);
    AName{k} = sprintf('a{%g} ',j);
  end
  if hasBias
    bName = sprintf('b{%g}',i);
  end
    
  % Layer Blocks
  genLayerOutput(net,i,y,layerNameL,outputName);
  genLayerTransfer(y,layerNameL,transferName,net.layers{i}.transferParam,...
    net.layers{i}.size);
  numSignals = numInputs+numLayers+hasBias;
  genLayerNet(numSignals,net.layers{i}.size,y,dy,layerNameL,netInputName);
  for k=1:numInputs
    j = inputInd(k);
    genInputSignal(net,i,j,k,layerNameL,PName{k},st);
    genInputDelays(net,i,j,k,layerNameL,IDName{k},st);
    genInputWeight(net,i,j,k,layerNameL,IWName{k},st);
  end
  for k=1:numLayers
    j = layerInd(k);
    genLayerSignal(net,i,j,k+numInputs,layerNameL,AName{k},st);
    genLayerDelays(net,i,j,k+numInputs,layerNameL,LDName{k},st);
    genLayerWeight(net,i,j,k+numInputs,layerNameL,LWName{k},st);
  end
  if hasBias
   genLayerBias(net,i,numInputs+numLayers+1,layerNameL,bName);
  end
  
  % Layer Block Connections
  for j=1:numInputs
    add_line(layerNameL,[PName{j} '/1'],[IDName{j} '/1'])
    add_line(layerNameL,[IDName{j} '/1'],[IWName{j} '/1'])
    add_line(layerNameL,[IWName{j} '/1'],[netInputName '/' num2str(j)])
  end
  for j=1:numLayers
    add_line(layerNameL,[AName{j} '/1'],[LDName{j} '/1'])
    add_line(layerNameL,[LDName{j} '/1'],[LWName{j} '/1'])
    add_line(layerNameL,[LWName{j} '/1'],[netInputName '/' num2str(j+numInputs)])
  end
  if hasBias
    add_line(layerNameL,[bName '/1'],[netInputName '/' num2str(numInputs+numLayers+1)])
  end
  add_line(layerNameL,[netInputName '/1'],[transferName '/1'])
  add_line(layerNameL,[transferName '/1'],[outputName '/1'])

%======================================================================
function genLayerOutput(net,i,y,layerNameL,outputName)

  outputNameL = [layerNameL '/' outputName];
  add_block('built-in/Outport',outputNameL,...
    'port','1',...
    'position',[420 y-20 460 y+20],...
    'InitialOutput',mat2str(zeros(net.layers{i}.size,1)),...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off');

%======================================================================
function genLayerTransfer(y,layerNameL,transferName,transferParam,s)

  transferNameL = [layerNameL '/' transferName];
  transferBlock = ['neural/Transfer Functions/' transferName];
  add_block(transferBlock,transferNameL,...
    'position',[340 y-20 380 y+20])
  param = feval(transferName,'simulinkParameters',s,transferParam);
  for j=1:size(param,1)
    set_param(transferNameL,param{j,1},param{j,2});
  end

%======================================================================
function genLayerNet(numSignals,numNeurons,y,dy,layerNameL,netInputName)

  if strcmp(netInputName,'netsum')
    maskStr = '+';
  elseif strcmp(netInputName,'netprod')
    maskStr = '*';
  else
    maskStr = '';
  end
  netInputNameL = [layerNameL '/' netInputName];
  if (numSignals > 1)
    netInputBlock = ['neural/Net Input Functions/' netInputName];
    add_block(netInputBlock,netInputNameL,...
      'inputs',num2str(numSignals),...
      'position',[260 y-20 300 y+20],...
      'maskdisplay',[transformMask 'disp(''' maskStr ''');'],...
      'MaskIconFrame','off');
  elseif (numSignals == 1)
    % Special case: numSignals == 1
    % netInputBlocks fail when there is only 1 signal,
    % summing across neurons instead of across signals.
    add_block('built-in/Gain',netInputNameL,...
      'gain','1',...
      'position',[260 y-dy 300 y+dy],...
      'maskdisplay',[transformMask 'disp(''' maskStr ''');'],...
      'MaskIconFrame','off');
  else
    % Special case: numSignals == 0
    % The default net input value is represented with a contant
    n = feval(netInputName,{},1,1) + zeros(numNeurons,1);
    add_block('built-in/Constant',netInputNameL,...
      'value',mat2str(n),...
      'position',[260 y-dy 300 y+dy],...
      'maskdisplay',[transformMask 'disp(''' maskStr ''');'],...
      'MaskIconFrame','off');
  end

%======================================================================
function genLayerBias(net,i,pos,layerNameL,bName)

  add_block('built-in/Constant',[layerNameL '/' bName],...
    'value',mat2str(net.b{i},100),...
    'position',[180 pos*60-20 220 pos*60+20],...
    'maskdisplay',[transformMask 'disp(''b'');'],...
    'MaskIconFrame','off');
    
%======================================================================
function genInputSignal(net,i,j,pos,layerNameL,PName,st)

  size = net.inputs{j}.processedSize;
  add_block('built-in/Inport',[layerNameL '/' PName],...
    'port',sprintf('%g',pos),...
    'portwidth',num2str(size),...
    'sampletime',st,...
    'position',[20 pos*60-20 60 pos*60+20],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off');

%======================================================================
function genInputDelays(net,i,j,pos,layerNameL,IDName,st)

  % Constants
  delays = net.inputWeights{i,j}.delays;
  numDelays = length(delays);
  minDelay = delays(1);
  maxDelay = delays(end);
  
  % Mask String
  if (minDelay == maxDelay)
    maskStr = num2str(minDelay);
  elseif numDelays == (maxDelay - minDelay + 1)
    maskStr = [num2str(minDelay) '-' num2str(maxDelay)];
  else
    maskStr = [num2str(minDelay) '...' num2str(maxDelay)];
  end
  
  % System
  name = IDName;
  nameL = [layerNameL '/' name];
  add_block('built-in/SubSystem',nameL)
  set_param(nameL,...
    'position',[100 pos*60-20 140 pos*60+20],...
    'maskdisplay','disp(''TDL'')',...
    'maskdisplay',[transformMask 'disp(''' maskStr ''');'],...
    'MaskIconFrame','off');
  
  % Names
  PName = sprintf('p{%g}',i);
  DName = cell(1,maxDelay);
  for k=1:maxDelay
    DName{k} = sprintf('Delay %g',k);
  end
  MuxName = 'mux';
  PDName = sprintf('pd{%g,%g}',i,j);
  
  % Blocks
  y = numDelays*20;
  add_block('built-in/Inport',[nameL '/' PName],...
    'port',sprintf('%g',1),...
    'portwidth',num2str(net.inputs{j}.processedSize),...
    'sampletime',st,...
    'position',[60 40 80 60],...
    'Orientation','down',...
    'NamePlacement','alternate',...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off')
  for k=1:maxDelay
    add_block('built-in/UnitDelay',[nameL '/' DName{k}],...
      'X0',['pi_input_' num2str(j) '_delayed_' num2str(k)],...
      'SampleTime',st,...
      'position',[60 40+k*40 80 60+k*40],...
      'Orientation','down',...
      'NamePlacement','alternate',...
      'maskdisplay',[transformMask 'disp(''D'')';],...
      'MaskIconFrame','off')
  end
  add_block('built-in/Mux',[nameL '/' MuxName],...
    'inputs',num2str(numDelays),...
    'position',[200 40+y 240 60+y],...
    'maskdisplay',[transformMask 'disp(''Mux'')';],...
    'MaskIconFrame','off')
  add_block('built-in/Outport',[nameL '/' PDName],...
    'port','1',...
    'position',[300 40+y 320 60+y],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off')
  
  % Connections
  for k=1:maxDelay
    if k == 1
      add_line(nameL,[PName '/1'],[DName{k} '/1'])
    else
      add_line(nameL,[DName{k-1} '/1'],[DName{k} '/1'])
    end
  end
  for k=1:numDelays
    if delays(k) == 0
      add_line(nameL,[PName '/1'],[MuxName '/' num2str(k)])
    else
      add_line(nameL,[DName{delays(k)} '/1'],[MuxName '/' num2str(k)])
    end
  end
  add_line(nameL,[MuxName '/1'],[PDName '/1'])

%======================================================================
function genInputWeight(net,i,j,pos,layerNameL,IWName,st)

  % System
  weightName = IWName;
  weightNameL = [layerNameL '/' weightName];
  add_block('built-in/SubSystem',weightNameL)
  set_param(weightNameL,...
    'position',[180 pos*60-20 220 pos*60+20],...
    'maskdisplay',[transformMask 'disp(''W'');'],...
    'MaskIconFrame','off');

  % Names
  for k=1:net.layers{i}.size
    weightVectorName{k} = sprintf('IW{%g,%g}(%g,:)''',i,j,k);
    vectorOpName{k} = [net.inputWeights{i,j}.weightFcn num2str(k)];
  end
  muxName = 'Mux';
  outputName = ['iz{' num2str(i) ',' num2str(j) '}'];
  PName = sprintf('pd{%g,%g}',i,j);
  
  % Vertical Spread
  dy = floor(min(60,10000 / net.layers{i}.size));
 
  % Blocks
  y = net.layers{i}.size * floor(dy/2) + 40;
  add_block('built-in/Inport',[weightNameL '/' PName],...
    'port',sprintf('%g',1),...
    'portwidth',num2str(net.inputWeights{i,j}.size(2)),...
    'sampletime',st,...
    'position',[40 y-10 60 y+10],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off')

  for k=1:net.layers{i}.size
    nameL = [weightNameL '/' vectorOpName{k}];
    block = ['neural/Weight Functions/' net.inputWeights{i,j}.weightFcn];
    add_block(block,nameL,...
      'position',[240 40+(k-1)*dy 260 80+(k-1)*dy])
    
    add_block('built-in/Constant',[weightNameL '/' weightVectorName{k}],...
      'value',mat2str(net.IW{i,j}(k,:)',100),...
      'position',[140 40+(k-1)*dy 180 60+(k-1)*dy],...
      'maskdisplay',[transformMask 'disp(''Weights'');'],...
      'MaskIconFrame','off')
  end

  add_block('built-in/Mux',[weightNameL '/' muxName],...
    'inputs',num2str(net.layers{i}.size),...
    'position',[340 y-10 380 y+10],...
    'maskdisplay',[transformMask 'disp(''Mux'');'],...
    'MaskIconFrame','off')

  outputNameL = [weightNameL '/' outputName];
  add_block('built-in/Outport',outputNameL,...
    'port','1',...
    'position',[420 y-10 440 y+10],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off')
  
  % Connections
  for k=1:net.layers{i}.size
    add_line(weightNameL,[weightVectorName{k} '/1'],[vectorOpName{k} '/1'])
    add_line(weightNameL,[PName '/1'],[vectorOpName{k} '/2'])
    add_line(weightNameL,[vectorOpName{k} '/1'],[muxName '/' num2str(k)])
  end
  add_line(weightNameL,[muxName '/1'],[outputName '/1'])

%======================================================================
function genLayerSignal(net,i,j,pos,layerNameL,AName,st)

  % Layer Signal
  add_block('built-in/Inport',[layerNameL '/' AName],...
    'port',sprintf('%g',pos),...
    'portwidth',num2str(net.layers{j}.size),...
    'sampletime',st,...
    'position',[20 pos*40-20 60 pos*40+20],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off');
 
%======================================================================
function genLayerDelays(net,i,j,pos,layerNameL,LDName,st)

  % Constants
  delays = net.layerWeights{i,j}.delays;
  numDelays = length(delays);
  minDelay = delays(1);
  maxDelay = delays(end);
  
  % Mask String
  if (minDelay == maxDelay)
    maskStr = num2str(minDelay);
  elseif numDelays == (maxDelay - minDelay + 1)
    maskStr = [num2str(minDelay) '-' num2str(maxDelay)];
  else
    maskStr = [num2str(minDelay) '...' num2str(maxDelay)];
  end
  
  % System
  name = LDName;
  nameL = [layerNameL '/' name];
  add_block('built-in/SubSystem',nameL)
  set_param(nameL,...
    'position',[100 pos*60-20 140 pos*60+20],...
    'maskdisplay','disp(''TDL'')',...
    'maskdisplay',[transformMask 'disp(''' maskStr ''');'],...
    'MaskIconFrame','off');

  % Names
  PName = sprintf('p{%g}',i);
  DName = cell(1,maxDelay);
  for k=1:maxDelay
    DName{k} = sprintf('Delay %g',k);
  end
  MuxName = 'mux';
  ADName = sprintf('pd{%g,%g}',i,j);
  
  % Blocks
  y = numDelays*20;
  add_block('built-in/Inport',[nameL '/' PName],...
    'port',sprintf('%g',1),...
    'portwidth',num2str(net.layers{j}.size),...
    'sampletime',st,...
    'position',[60 40 80 60],...
    'Orientation','down',...
    'NamePlacement','alternate',...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off')
  for k=1:maxDelay
    add_block('built-in/UnitDelay',[nameL '/' DName{k}],...
      'X0',['ai_layer_' num2str(j) '_delayed_' num2str(k)],...
      'SampleTime',st,...
      'position',[60 40+k*40 80 60+k*40],...
      'Orientation','down',...
      'NamePlacement','alternate',...
      'maskdisplay',[transformMask 'disp(''D'')';],...
      'MaskIconFrame','off')
  end
  add_block('built-in/Mux',[nameL '/' MuxName],...
    'inputs',num2str(numDelays),...
    'position',[200 40+y 240 60+y],...
    'maskdisplay',[transformMask 'disp(''Mux'')';],...
    'MaskIconFrame','off')
  add_block('built-in/Outport',[nameL '/' ADName],...
    'port','1',...
    'position',[300 40+y 320 60+y],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off')
  
  % Connections
  for k=1:maxDelay
    if k == 1
      add_line(nameL,[PName '/1'],[DName{k} '/1'])
    else
      add_line(nameL,[DName{k-1} '/1'],[DName{k} '/1'])
    end
  end
  for k=1:numDelays
    if delays(k) == 0
      add_line(nameL,[PName '/1'],[MuxName '/' num2str(k)])
    else
      add_line(nameL,[DName{delays(k)} '/1'],[MuxName '/' num2str(k)])
    end
  end
  add_line(nameL,[MuxName '/1'],[ADName '/1'])

%======================================================================
function genLayerWeight(net,i,j,pos,layerNameL,LWName,st)

  % System
  weightName = LWName;
  weightNameL = [layerNameL '/' weightName];
  add_block('built-in/SubSystem',weightNameL)
  set_param(weightNameL,...
    'position',[180 pos*60-20 220 pos*60+20],...
    'maskdisplay',[transformMask 'disp(''W'');'],...
    'MaskIconFrame','off');

  % Names
  for k=1:net.layers{i}.size
    weightVectorName{k} = sprintf('IW{%g,%g}(%g,:)''',i,j,k);
    vectorOpName{k} = [net.layerWeights{i,j}.weightFcn num2str(k)];
  end
  muxName = 'Mux';
  outputName = ['lz{' num2str(i) ',' num2str(j) '}'];
  AName = sprintf('ad{%g,%g}',i,j);
  
  % Vertical Spread
  dy = floor(min(60,10000 / net.layers{i}.size));
  
  % Blocks
  y = net.layers{i}.size * floor(dy/2) + 40;
  add_block('built-in/Inport',[weightNameL '/' AName],...
    'port',sprintf('%g',1),...
    'portwidth',num2str(net.layerWeights{i,j}.size(2)),...
    'sampletime',st,...
    'position',[40 y-10 60 y+10],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off')

  for k=1:net.layers{i}.size
    nameL = [weightNameL '/' vectorOpName{k}];
    block = ['neural/Weight Functions/' net.layerWeights{i,j}.weightFcn];
    add_block(block,nameL,...
      'position',[240 40+(k-1)*dy 260 80+(k-1)*dy])
    
    add_block('built-in/Constant',[weightNameL '/' weightVectorName{k}],...
      'value',mat2str(net.LW{i,j}(k,:)',100),...
      'position',[140 40+(k-1)*dy 180 60+(k-1)*dy],...
      'maskdisplay',[transformMask 'disp(''weights'');'],...
    'MaskIconFrame','off')
  end

  add_block('built-in/Mux',[weightNameL '/' muxName],...
    'inputs',num2str(net.layers{i}.size),...
    'position',[340 y-10 380 y+10],...
    'maskdisplay',[transformMask 'disp(''Mux'');'],...
    'MaskIconFrame','off')

  outputNameL = [weightNameL '/' outputName];
  add_block('built-in/Outport',outputNameL,...
    'port','1',...
    'position',[420 y-10 440 y+10],...
    'maskdisplay',signalMask,...
    'MaskIconFrame','off')
  
  % Connections
  for k=1:net.layers{i}.size
    add_line(weightNameL,[weightVectorName{k} '/1'],[vectorOpName{k} '/1'])
    add_line(weightNameL,[AName '/1'],[vectorOpName{k} '/2'])
    add_line(weightNameL,[vectorOpName{k} '/1'],[muxName '/' num2str(k)])
  end
  add_line(weightNameL,[muxName '/1'],[outputName '/1'])

%======================================================================

function uname = uniquename(name,names)

if isempty(nnstring.first_match(name,names))
  uname = name;
else
  i = 2;
  uname = [name num2str(i)];
  while ~isempty(nnstring.first_match(uname,names))
    uname = [name num2str(i)];
    i = i+1;
  end
end

%======================================================================

function mask = signalMask
persistent MASK;
if isempty(MASK)
  MASK = {...
    'e = 0.06;';
    'c1 = [120 230 180]/255;';
    'c2 = ([120 230 180]+0)/(256+128);';
    'c3 = ([120 230 180]+128)/(256+128);';
    'patch([0 1 1 0],[0 0 1 1],c1);';
    'patch([0 1 1 1-e 1-e 0+e],[0 0 1 1-e 0+e 0+e],c2);';
    'patch([0 0 1 1-e 0+e 0+e],[0 1 1 1-e 1-e 0+e],c3);';
    'plot([0 1 1 0 0],[0 0 1 1 0]);'};
  MASK = [MASK{:}];
end
mask = MASK;

function mask = transformMask
persistent MASK;
if isempty(MASK)
  MASK = {...
  'e = 0.06;';
  'c1 = [120 150 230]/255;';
  'c2 = ([120 150 230]+0)/383;';
  'c3 = ([120 150 230]+128)/383;';
  'patch([0 1 1 0],[0 0 1 1],c1);';
  'patch([0 1 1 1-e 1-e 0+e],[0 0 1 1-e 0+e 0+e],c2);';
  'patch([0 0 1 1-e 0+e 0+e],[0 1 1 1-e 1-e 0+e],c3);';
  'plot([0 1 1 0 0],[0 0 1 1 0]);'};
  MASK = [MASK{:}];
end
mask = MASK;
