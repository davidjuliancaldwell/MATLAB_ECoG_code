function result = tools(command,varargin)

% Copyright 2007-2012 The MathWorks, Inc.

if nargout > 0, result = []; end

persistent JAVA_TOOLS;
if isempty(JAVA_TOOLS)
  nnpath.add_jar;
  JAVA_TOOLS = javaObjectEDT('com.mathworks.toolbox.nnet.matlab.nnTools');
  JAVA_TOOLS.initialize(matlabroot,nnpath.nnet_toolbox,nnDependency.simulinkAvailable);
end

try
  switch command

    case 'initialize'
      % Initialization happens above, no need to do more here
      
    %% CALLS FROM JAVA

    case 'getWorkspaceVariables'
      [names,cTypes,rTypes,sizes,isCells,numFinites] = getWorkspaceVariables();
      result = nnjava.tools('vector');
      addElement(result,names);
      addElement(result,cTypes);
      addElement(result,rTypes);
      addElement(result,sizes);
      addElement(result,isCells)
      addElement(result,numFinites);

    case 'loadDataset'
      prefix = varargin{1};
      evalin('base',['load ' prefix '_dataset']);

    case 'get_java_transfer_function'
      tfname = nnjava.tools('string',varargin{1});
      result = JAVA_TOOLS.getTransferFunction(tfname);

    case 'importData'
      name = import_data();
      result = nnjava.tools('string',name);
      
    case 'doc'
      doc(varargin{1});

  %% CALLS FROM MATLAB

    case 'nnstart'
      result = JAVA_TOOLS.getNNStartTool;
  
    case 'nctool'
      result = JAVA_TOOLS.getNCTool;

    case 'nftool'
      result = JAVA_TOOLS.getNFTool;

    case 'nprtool'
      result = JAVA_TOOLS.getNPRTool;

    case 'ntstool'
      result = JAVA_TOOLS.getNTSTool;
      
    case 'nntraintool'
      result = JAVA_TOOLS.getNNTrainTool;
      
    case 'nntool'
      result = JAVA_TOOLS.getNNTool;

    case 'diagram'
      nnassert.minargs(nargin,2);
      diagram = JAVA_TOOLS.newDiagram;
      net = struct(varargin{1});
      dynamic = ~all([net.numInputDelays net.numLayerDelays net.numFeedbackDelays] == 0);
      diagram.showInputSizes.set(true);
      diagram.showLayerSizes.set(true);
      diagram.showDimensions(true);
      if isempty(net.name)
        diagram.name.set('Neural Network');
      else
        diagram.name.set(net.name);
      end
      inputs = cell(1,net.numInputs);
      for i=1:net.numInputs
        fb = ~isempty(net.inputs{i}.feedbackOutput);
        inputs{i} = diagram.newInput;
        if dynamic
          inputName = [net.inputs{i}.name '(t)'];
        else
          inputName = net.inputs{i}.name;
        end
        inputs{i}.inputProperties.name.set(nnjava.tools('string',inputName));
        inputs{i}.inputProperties.size.set(int32(net.inputs{i}.size));
        inputs{i}.inputProperties.isFeedback.set(fb);
      end
      layers = cell(1,net.numLayers);
      for i=1:net.numLayers
        layers{i} = diagram.newLayer;
        layers{i}.layerProperties.name.set(nnjava.tools('string',net.layers{i}.name));
        layers{i}.layerProperties.size.set(int32(net.layers{i}.size));
        if net.biasConnect(i)
          layers{i}.layerProperties.hasBias.set(true);
        end
      end
      outputs = cell(1,net.numOutputs);
      output2layers = find(net.outputConnect);
      for i=1:net.numOutputs
        ii = output2layers(i);
        fb = strcmp(net.outputs{ii}.feedbackMode,'open');
        outputs{i} = diagram.newOutput;
        if ~dynamic
          outputName = net.outputs{ii}.name;
        else
          outputDelays = net.outputs{ii}.feedbackDelay;
          if outputDelays == 0
            outputName = [net.outputs{ii}.name '(t)'];
          elseif (outputDelays < 0)
            outputName = [net.outputs{ii}.name '(t' num2str(outputDelays) ')'];
          else
            outputName = [net.outputs{ii}.name '(t+' num2str(outputDelays) ')'];
          end
        end
        outputs{i}.outputProperties.name.set(nnjava.tools('string',outputName));
        outputs{i}.outputProperties.size.set(int32(net.outputs{ii}.size));
        outputs{i}.outputProperties.predictDelay.set(int32(net.outputs{ii}.feedbackDelay));
        outputs{i}.outputProperties.isFeedback.set(fb);
      end
      weightGroups = cell(1,net.numLayers);
      numWeights = zeros(1,net.numLayers);
      outputIndex = 1;
      for i=1:net.numLayers
        for j=1:net.numInputs
          if net.inputConnect(i,j)
            weightGroup = layers{i}.newWeightGroup;
            delays = net.inputWeights{i,j}.delays;
            if isempty(delays)
              minDelay = -1;
              maxDelay = -1;
              allDelays = false;
            else
              minDelay = delays(1);
              maxDelay = delays(end);
              allDelays = length(delays) == (maxDelay-minDelay+1);
            end
            if (minDelay ~= 0) || (maxDelay ~= 0)
              weightGroup.showDelays.set(true);
              weightGroup.minDelay.set(int32(minDelay));
              weightGroup.maxDelay.set(int32(maxDelay));
              weightGroup.allDelays.set(allDelays);
            end
            weightGroups{i} = [weightGroups{i} {weightGroup}];
            diagram.newInputToLayerConnection(i-1,j-1,numWeights(i));
            numWeights(i) = numWeights(i) + 1;
          end
        end
        for j=1:net.numLayers
          jTransferFunction = nnjava.tools('get_java_transfer_function',net.layers{i}.transferFcn);
          layers{i}.layerProperties.transferFunction.set(jTransferFunction);
          if net.layerConnect(i,j)
            weightGroup = layers{i}.newWeightGroup;
            delays = net.layerWeights{i,j}.delays;
            if isempty(delays)
              minDelay = -1;
              maxDelay = -1;
              allDelays = false;
            else
              minDelay = delays(1);
              maxDelay = delays(end);
              allDelays = length(delays) == (maxDelay-minDelay+1);
            end
            if (minDelay ~= 0) || (maxDelay ~= 0)
              weightGroup.showDelays.set(true);
              weightGroup.minDelay.set(int32(minDelay));
              weightGroup.maxDelay.set(int32(maxDelay));
              weightGroup.allDelays.set(allDelays);
            end
            weightGroups{i} = [weightGroups{i} {weightGroup}];
            diagram.newLayerToLayerConnection(i-1,j-1,numWeights(i));
            numWeights(i) = numWeights(i) + 1;
          end
        end
        if net.outputConnect(i)
          diagram.newLayerToOutputConnection(outputIndex-1,i-1);
          outputIndex = outputIndex + 1;
        end
      end
      diagram.layoutChildren;
      result = diagram;
      
    case 'view'
      net = struct(varargin{1});
      diagram = nnjava.tools('diagram',net);
      netview = JAVA_TOOLS.newView(diagram);
      if nargout > 0, result = netview; end
      drawnow
      nngui.publish_java_window(netview);
      
    case 'error'
      errmsg = varargin{1};
      result = JAVA_TOOLS.newError(errmsg);

    case 'string'
      result = javaObjectEDT('java.lang.String',varargin{1});
      
    case 'vector'
      result = javaObjectEDT('java.util.Vector');
      
    case 'double'
      result = javaObjectEDT('java.lang.Double',varargin{1});
      
    case 'integer'
      result = javaObjectEDT('java.lang.Integer',varargin{1});
      
    case 'true'
      result = javaObjectEDT('java.lang.Boolean',true);
    
    case 'false'
      result = javaObjectEDT('java.lang.Boolean',false);
      
    case 'stringarray'
      result = JAVA_TOOLS.newStringArray(varargin{1});
      
    case 'doublearray'
      result = JAVA_TOOLS.newDoubleArray(varargin{1});
      
    case 'isa'
      x = varargin{1};
      c = varargin{2};
      c(c=='_') = '.';
      result = isa(x,c);
      
    otherwise, nnerr.throw(['Unrecognized command: ' command]);
  end
catch me
  errmsg = me.message;
  errmsg(errmsg<32) = ',';
  errmsg = nnjava.tools('string',errmsg);
  result = JAVA_TOOLS.newError(errmsg);
end

%----------------------------------------------------------
function [names,standardTypes,transposedTypes,sizes,isCells,numFinites] = getWorkspaceVariables()
names = nnjava.tools('vector');
standardTypes = nnjava.tools('vector');
transposedTypes = nnjava.tools('vector');
sizes = nnjava.tools('vector');
isCells = nnjava.tools('vector');
numFinites = nnjava.tools('vector');
variables = evalin('base','who');
for i=1:length(variables)
  name = variables{i};
  if ~strcmp(name,'ans')
    value = evalin('base',name);
    if nntype.data('isa',value) && (~iscell(value) || (nnfast.numsignals(value)==1))
      % TODO - accept cell container for matrix row/col time
      if iscell(value)
        standardType = nn_type_category([value{:}]);
        transposedType = nn_type_category(vertcat(value{:})');
        if isempty(value)
          dimensions = [size(value,2) 0 0];
        else
          dimensions = [size(value,2) size(value{1},1) size(value{1},2)];
        end
        isCell = nnjava.tools('true');
        numFinite = nnfast.numfinite(value);
      else
        standardType = nn_type_category(value);
        transposedType = nn_type_category(value');
        dimensions = [1 size(value,1) size(value,2)];
        isCell = nnjava.tools('false');
        numFinite = sum(sum(isfinite(value)));
      end
      addElement(names,nnjava.tools('string',name));
      addElement(standardTypes,nnjava.tools('string',standardType));
      addElement(transposedTypes,nnjava.tools('string',transposedType));
      addElement(sizes,dimensions);
      addElement(isCells,isCell);
      addElement(numFinites,nnjava.tools('integer',numFinite));
    end
  end
end

%%
function type = nn_type_category(x)

type = '.';
if isa(x,'network') && (numel(x) == 1)
  type = [type 'NETWORK.'];
elseif ~(isnumeric(x) || islogical(x)) || ischar(x)
  % Nothing
elseif (ndims(x) == 2) && ~isempty(x)
  if iscell(x)
    type = [type 'CELL. '];
    x = cell2mat(x);
  else
    type = [type 'MATRIX. '];
  end
  if isnumeric(x) || islogical(x)
    type = [type 'NUMERIC.'];
  end
  if ischar(x), type = [type 'CHAR.']; end
  xsum = sum(x,1);
  if all((xsum==1) | isnan(xsum)) && all(all(((x>=0) & (x<=1)) | isnan(x)))
    type = [type 'NORMALIZED.'];
  end
  if all(all((x == 0) | (x == 1) | isnan(x)))
    type = [type 'LOGICAL.'];
  end
  if all(all((x >= 0) | isnan(x)))
    type = [type 'POSITIVE.'];
  end
else
  type = '?';
end

%%
function name = import_data()

name = '';
S = uiimport('-file');
if ~isempty(S)
  names = fields(S);
  for i=1:length(names)
    n = names{i};
    value = S.(n);
    assignin('base',n,value);
    if isempty(name) && nntype.single_sequence('isa',value)
      name = n;
    end
  end
end

%%

