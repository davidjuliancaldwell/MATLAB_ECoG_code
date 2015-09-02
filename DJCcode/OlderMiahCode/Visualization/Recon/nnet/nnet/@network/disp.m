function disp(net,inputname)
%DISP Display a neural network's properties.
%
%  <a href="matlab:doc disp">disp</a>(NET) display's a network's properties at the command line.
%
%  Here a network is created and displayed.
%
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(20);
%    <a href="matlab:doc disp">disp</a>(net)
%
%  See also DISPLAY, SIM, INIT, TRAIN, ADAPT, VIEW.

%  Mark Beale, 11-31-97
%  Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.7.4.13 $

% Convert from Network to Struct
net = struct(net);

if (nargin == 1) || (length(dbstack) > 2)
  inputname = '';
end
str = disp_str(net,inputname);
str = nnlink.filterLinks(str);
for i=1:length(str), disp(str{i}), end

function str = disp_str(net,inputname)

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

str = {'    Neural Network'};
if (isLoose), str{end+1} = ' '; end

str{end+1} = [nnlink.prop2link('net','name') nnstring.str2str(net.name)];
str{end+1} = [nnlink.prop2link('net','efficiency'),efficiency2str(net.efficiency)];
str{end+1} = [nnlink.prop2link('net','userdata') '(your custom info)'];

if (isLoose), str{end+1} = ' '; end
str{end+1} = nn_dispsubtitle('dimensions');
if (isLoose), str{end+1} = ' '; end

str{end+1} = [nnlink.prop2link('net','numInputs') num2str(net.numInputs)];
str{end+1} = [nnlink.prop2link('net','numLayers') num2str(net.numLayers)];
str{end+1} = [nnlink.prop2link('net','numOutputs') num2str(net.numOutputs)'];
str{end+1} = [nnlink.prop2link('net','numInputDelays') num2str(net.numInputDelays)];
str{end+1} = [nnlink.prop2link('net','numLayerDelays') num2str(net.numLayerDelays)];
str{end+1} = [nnlink.prop2link('net','numFeedbackDelays') num2str(net.numLayerDelays)];
str{end+1} = [nnlink.prop2link('net','numWeightElements') num2str(net.numWeightElements)];
str{end+1} = [nnlink.prop2link('net','sampleTime') num2str(net.sampleTime)];

if (isLoose), str{end+1} =  ' '; end
str{end+1} = nn_dispsubtitle('connections');
if (isLoose), str{end+1} =  ' '; end

str{end+1} = [nnlink.prop2link('net','biasConnect'),nnstring.bool2str(net.biasConnect)];
str{end+1} = [nnlink.prop2link('net','inputConnect'),nnstring.bool2str(net.inputConnect)];
str{end+1} = [nnlink.prop2link('net','layerConnect'),nnstring.bool2str(net.layerConnect)];
str{end+1} = [nnlink.prop2link('net','outputConnect'),nnstring.bool2str(net.outputConnect)];

if (isLoose), str{end+1} = ' '; end
str{end+1} = nn_dispsubtitle('subobjects');
if (isLoose), str{end+1} = ' '; end

str{end+1} = [nnlink.prop2link('net','inputs'),nnstring.objs2str(net.inputs,'nnetInput',inputname,'inputs')];
str{end+1} = [nnlink.prop2link('net','layers'),nnstring.objs2str(net.layers,'nnetLayer',inputname,'layers')];
str{end+1} = [nnlink.prop2link('net','outputs'),nnstring.objs2str(net.outputs,'nnetOutput',inputname,'outputs')];
str{end+1} = [nnlink.prop2link('net','biases'),nnstring.objs2str(net.biases,'nnetBias',inputname,'biases')];
str{end+1} = [nnlink.prop2link('net','inputWeights'),nnstring.objs2str(net.inputWeights,'nnetWeight',inputname,'inputWeights')];
str{end+1} = [nnlink.prop2link('net','layerWeights'),nnstring.objs2str(net.layerWeights,'nnetWeight',inputname,'layerWeights')];

if (isLoose), str{end+1} = ' '; end
str{end+1} = nn_dispsubtitle('functions');
if (isLoose), str{end+1} = ' '; end

str{end+1} = [nnlink.prop2link('net','adaptFcn'),nnlink.fcn2strlink(net.adaptFcn)];
str{end+1} = [nnlink.prop2link('net','adaptParam'),nnlink.paramstruct2str(net.adaptParam)];
str{end+1} = [nnlink.prop2link('net','derivFcn'),nnlink.fcn2strlink(net.derivFcn)];
str{end+1} = [nnlink.prop2link('net','divideFcn'),nnlink.fcn2strlink(net.divideFcn)];
str{end+1} = [nnlink.prop2link('net','divideParam'),nnlink.paramstruct2str(net.divideParam)];
str{end+1} = [nnlink.prop2link('net','divideMode') '''' net.divideMode ''''];
str{end+1} = [nnlink.prop2link('net','initFcn'),nnlink.fcn2strlink(net.initFcn)];
str{end+1} = [nnlink.prop2link('net','performFcn'),nnlink.fcn2strlink(net.performFcn)];
str{end+1} = [nnlink.prop2link('net','performParam'),nnlink.paramstruct2str(net.performParam)];
str{end+1} = [nnlink.prop2link('net','plotFcns'),nnlink.fcns2links(net.plotFcns)];
str{end+1} = [nnlink.prop2link('net','plotParams') nnstring.objs2str(net.plotParams,'nnetParam',inputname,'plotParams')];
str{end+1} = [nnlink.prop2link('net','trainFcn'),nnlink.fcn2strlink(net.trainFcn)];
str{end+1} = [nnlink.prop2link('net','trainParam'),nnlink.paramstruct2str(net.trainParam)];

if (isLoose), str{end+1} = ' '; end
str{end+1} = nn_dispsubtitle('weight and bias values');
if (isLoose), str{end+1} = ' '; end

numIW = sum(sum(net.inputConnect));
numLW = sum(sum(net.layerConnect));
numB = sum(net.biasConnect);
str{end+1} = [nnlink.prop2link('net','IW'),sprintf('{%gx%g cell} containing %g %s',...
  net.numLayers,net.numInputs,numIW,...
  nnstring.plural(numIW,'input weight matrix'))];
str{end+1} = [nnlink.prop2link('net','LW'),sprintf('{%gx%g cell} containing %g %s',...
  net.numLayers,net.numLayers,numLW,...
  nnstring.plural(numLW,'layer weight matrix'))];
str{end+1} = [nnlink.prop2link('net','b'),sprintf('{%gx1 cell} containing %g %s',...
  net.numLayers,numB,...
  nnstring.plural(active(net.biases),'bias vector'))];

if (isLoose), str{end+1} = ' '; end
str{end+1} = nn_dispsubtitle('methods');
if (isLoose), str{end+1} = ' '; end

%if ~isempty(inputname)
%  spaces = repmat(' ',1,18-length(inputname));
%  disp([spaces nnlink.str2link(inputname,'matlab: doc network/sim') ': Evaluate network outputs given inputs.']);
%end

str{end+1} = nnstring.method2str('adapt','Learn while in continuous use');
str{end+1} = nnstring.method2str('configure','Configure inputs & outputs');
str{end+1} = nnstring.method2str('gensim','Generate Simulink model',inputname);
str{end+1} = nnstring.method2str('init','Initialize weights & biases',inputname);
str{end+1} = nnstring.method2str('perform','Calculate performance');
str{end+1} = nnstring.method2str('sim','Evaluate network outputs given inputs');
str{end+1} = nnstring.method2str('train','Train network with examples');
str{end+1} = nnstring.method2str('view','View diagram',inputname);
str{end+1} = nnstring.method2str('unconfigure','Unconfigure inputs & outputs',inputname);

if (isLoose), str{end+1} = ' '; end

if ~isempty(inputname)
  if (net.numInputDelays == 0) && (net.numLayerDelays== 0)
    ss = ['outputs = ' inputname '(inputs)'];
  elseif (net.numInputDelays > 0) && (net.numLayerDelays == 0)
    ss = ['[outputs,inputStates] = ' inputname '(inputs,inputStates)'];
  elseif (net.numInputDelays == 0) && (net.numLayerDelays > 0)
    ss = ['[outputs,ignore,layerStates] = ' inputname '(inputs,{},layerStates)'];
  else
    ss = ['[outputs,inputStates,layerStates] = ' inputname '(inputs,inputState,layerStates)'];
  end
  str{end+1} = [nn_dispsubtitle('evaluate') '       ' ss]; %nnlink.str2link(ss,'matlab:doc network/sim')];
  if (isLoose), str{end+1} = ' '; end
end

function str = nn_dispsubtitle(str)
str = ['    ' str ':'];

function str = efficiency2str(x,doLinks)

% Copyright 2010 The MathWorks, Inc.

if nargin < 2
  doLinks = true;
end

x = struct(x);

f = fieldnames(x);
n = length(f);
if n == 0
  str = '(none)';
else
  fi = f{1};
  if doLinks
    str = ['.' nnlink.str2link(fi,['matlab:doc nnproperty.net_efficiency_' fi])];
  else
    str = ['.' fi];
  end
  len = 1 + length(fi);
  for i=2:n
    str = [str ','];
    len = len + 1;
    fi = f{i};
    if doLinks
      xi = nnlink.str2link(fi,['matlab:doc nnproperty.net_efficiency_' fi]);
    else
      xi = fi;
    end
    if (len + 2 + length(fi)) > 50
      str = [str '\n                    .' xi];
      len = 1 + length(fi);
    else
      str = [str ' .' xi];
      len = len + 2 + length(fi);
    end
  end
end

str = sprintf(str);



