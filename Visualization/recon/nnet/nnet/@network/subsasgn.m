function net=subsasgn(net,subscripts,v)
%SUBSASGN Assign fields of a neural network.

% Mark Beale, 11-31-97
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.14.4.17 $ $ Date: $

% Convert Network to Struct
net = struct(net);

netname = inputname(1);
if isempty(netname), netname = 'NET'; end
net = network_subsasgn(net,subscripts,v,netname);

function net = network_subsasgn(net,subscripts,v,netname)

persistent FIELD_NAMES;
if isempty(FIELD_NAMES)
  FIELD_NAMES.network = fieldnames(net);
  FIELD_NAMES.input = fieldnames(nn_new_input_struct);
  FIELD_NAMES.layer = fieldnames(newLayer);
  FIELD_NAMES.output = fieldnames(newOutput);
  FIELD_NAMES.bias = fieldnames(newBias);
  FIELD_NAMES.weight = fieldnames(newWeight);
  FIELD_NAMES.net_read_only = ...
    {'numOutputs','numInputDelays','numLayerDelays','numFeedbackDelays'};
end

% Assume no error
err = '';

% First subscript
[subscripts,field,type,moresubs] = nextsubs(subscripts);

switch type
case '.'
  
  if isdeployed, return, end

  field = matchstring(field,FIELD_NAMES.network);
  if ~isempty(nnstring.first_match(field,FIELD_NAMES.net_read_only))
    nnerr.throw('Property',['"net.' field '" is a read only property.'])
  end
  switch(field)
    
  % Network architecture
  case 'numInputs',
    [numInputs,err] = nsubsasn(net.numInputs,subscripts,v);
    if isempty(err), [net,err]=setNumInputs(net,numInputs); end
  case 'numLayers',
    [numLayers,err] = nsubsasn(net.numLayers,subscripts,v);
    if isempty(err), [net,err]=setNumLayers(net,numLayers); end
  case 'sampleTime'
    [sampleTime,err] = nsubsasn(net.sampleTime,subscripts,v);
    if isempty(err), [net,err] = setSampleTime(net,sampleTime); end
  
  case 'biasConnect',
    [biasConnect,err] = nsubsasn(net.biasConnect,subscripts,v);
    if isempty(err), [net,err]=setBiasConnect(net,biasConnect); end
  case 'inputConnect',
    [inputConnect,err] = nsubsasn(net.inputConnect,subscripts,v);
    if isempty(err), [net,err]=setInputConnect(net,inputConnect); end
  case 'layerConnect',
    [layerConnect,err] = nsubsasn(net.layerConnect,subscripts,v);
    if isempty(err), [net,err]=setLayerConnect(net,layerConnect); end
  case {'outputConnect','targetConnect'}
    % NNT 5 backward compatibility
    if strcmpi(field,'targetConnect')
      nnerr.obs_use(mfilename,'"targetConnect" is obsolete. Use "outputConnect" instead.');
    end
    [outputConnect,err] = nsubsasn(net.outputConnect,subscripts,v);
    if isempty(err), [net,err]=setOutputConnect(net,outputConnect); end
    
  % NNET 5.0 compatibility
  case 'numTargets'
    error(message('nnet:NNet:NumTargetsObsolete'))

  % Inputs
  case 'inputs',
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'.')
      [net,err] = nsubasgn_cellfield(net,field,subs,v,subscripts);
      if ~isempty(err),nnerr.throw('Property',err); end
      return
    end
    if strcmp(type,'.'), error(message('nnet:Math:CantAssignFieldToNonStruct')), end
    if strcmp(type,'()'), error(message('nnet:Math:CantAssignDoubleAsCell')), end
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [sub1,err] = subs1(subs,[net.numInputs 1]);
    if ~isempty(err), nnerr.throw('Property',err), end

    [subscripts,field,type] = nextsubs(subscripts);
    if strcmp(type,'{}'),error(message('nnet:Math:CantAssignNonCellAsCell')),end
    if strcmp(type,'()'),error(message('nnet:Math:CantAssignArrayAsNonArray')),end
    
    field = matchstring(field,FIELD_NAMES.input);
    
    % NNET 6.0 Compatibility
    if ~isempty(nnstring.first_match(field,{'feedbackOutput','processSettings','processedRange','processedSize'}))
      nnerr.throw('Property',['"net.inputs{i}.' field '" is a read only property.'])
    end
    for i=sub1,
      switch(field)
      case 'exampleInput'
        [exampleInput,err] = nsubsasn(net.inputs{i}.exampleInput,subscripts,v);
        if isempty(err), [net,err] = setInputExampleInput(net,i,exampleInput); end
      case 'name'
        [name,err] = nsubsasn(net.inputs{i}.name,subscripts,v);
        if isempty(err), [net,err] = setInputName(net,i,name); end
      case 'processFcns'
        [processFcns,err] = nsubsasn(net.inputs{i}.processFcns,subscripts,v);
        if isempty(err), [net,err] = setInputProcessFcns(net,i,processFcns); end
      case 'processParams'
        [processParam,err] = nsubsasn(net.inputs{i}.processParams,subscripts,v);
        if isempty(err), [net,err] = setInputProcessParam(net,i,processParam); end
      case 'range'
        [range,err] = nsubsasn(net.inputs{i}.range,subscripts,v);
        if isempty(err), [net,err] = setInputRange(net,i,range); end
      case 'size'
        [newSize,err] = nsubsasn(net.inputs{i}.size,subscripts,v);
        if isempty(err), [net,err] = setInputSize(net,i,newSize); end
      case 'userdata',
          [net.inputs{i}.userdata,err] = nsubsasn(net.inputs{i}.userdata,subscripts,v);
      otherwise,
        error(message('nnet:Math:NonexistentField'))
      end
    end
    
  % Layers
  case 'layers',
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'.')
      [net,err] = nsubasgn_cellfield(net,field,subs,v,subscripts);
      if ~isempty(err),nnerr.throw('Property',err); end
      return
    end
    if strcmp(type,'()'), error(message('nnet:Math:CantAssignDoubleAsCell')), end
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [sub1,err] = subs1(subs,[net.numLayers 1]);
    if ~isempty(err), nnerr.throw('Property',err), end

    [subscripts,field,type] = nextsubs(subscripts);
    if strcmp(type,'{}'),error(message('nnet:Math:CantAssignNonCellAsCell')),end
    if strcmp(type,'()'),error(message('nnet:Math:CantAssignArrayAsNonArray')),end
    
    field = matchstring(field,FIELD_NAMES.layer);
    if ~isempty(nnstring.first_match(field,{'distances','positions','range'}))
      nnerr.throw('Property',['"net.layers{i}.' field '" is a read only property.'])
    end
    for i=sub1,
      switch(field)
      case 'dimensions'
        [newDimensions,err] = nsubsasn(net.layers{i}.dimensions,subscripts,v);
        if isempty(err), [net,err] = setLayerDimensions(net,i,newDimensions); end
      case 'distanceFcn'
        [distanceFcn,err] = nsubsasn(net.layers{i}.distanceFcn,subscripts,v);
        if isempty(err), [net,err] = setLayerDistanceFcn(net,i,distanceFcn); end
      case 'distanceParam'
        [distanceParam,err] = nsubsasn(net.layers{i}.distanceParam,subscripts,v);
        if isempty(err), [net,err] = setLayerDistanceParam(net,i,distanceParam); end
      case 'initFcn'
        [initFcn,err] = nsubsasn(net.layers{i}.initFcn,subscripts,v);
        if isempty(err), [net,err] = setLayerInitFcn(net,i,initFcn); end
      case 'name'
        [name,err] = nsubsasn(net.layers{i}.name,subscripts,v);
        if isempty(err), [net,err] = setLayerName(net,i,name); end
      case 'netInputFcn'
        [netInputFcn,err] = nsubsasn(net.layers{i}.netInputFcn,subscripts,v);
        if isempty(err), [net,err] = setLayerNetInputFcn(net,i,netInputFcn); end
      case 'netInputParam'
        [netInputParam,err] = nsubsasn(net.layers{i}.netInputParam,subscripts,v);
        if isempty(err), [net,err] = setLayerNetInputParam(net,i,netInputParam); end
      case 'size'
        [newSize,err] = nsubsasn(net.layers{i}.size,subscripts,v);
        if isempty(err), [net,err] = setLayerSize(net,i,newSize); end
      case 'topologyFcn'
        [topologyFcn,err] = nsubsasn(net.layers{i}.topologyFcn,subscripts,v);
        if isempty(err), [net,err] = setLayerTopologyFcn(net,i,topologyFcn); end
      case 'transferFcn'
        [transferFcn,err] = nsubsasn(net.layers{i}.transferFcn,subscripts,v);
        if isempty(err), [net,err] = setLayerTransferFcn(net,i,transferFcn); end
      case 'transferParam'
        [transferParams,err] = nsubsasn(net.layers{i}.transferParam,subscripts,v);
        if isempty(err), [net,err] = setLayerTransferParam(net,i,transferParams); end
      case 'userdata',
        [net.layers{i}.userdata,err] = nsubsasn(net.layers{i}.userdata,subscripts,v);
      otherwise,
        error(message('nnet:Math:NonexistentField'))
      end
    end
  
  % Biases
  case 'biases',
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'.')
      [net,err] = nsubasgn_cellfield(net,field,subs,v,subscripts);
      if ~isempty(err),nnerr.throw('Property',err); end
      return
    end
    if strcmp(type,'.'), error(message('nnet:Math:CantAssignFieldToNonStruct')), end
    if strcmp(type,'()'), error(message('nnet:Math:CantAssignDoubleAsCell')), end
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [sub1,err] = subs1(subs,[net.numLayers 1]);
    if ~isempty(err), nnerr.throw('Property',err), end

    [subscripts,field,type] = nextsubs(subscripts);
    if strcmp(type,'{}'),error(message('nnet:Math:CantAssignNonCellAsCell')),end
    if strcmp(type,'()'),error(message('nnet:Math:CantAssignArrayAsNonArray')),end
    
    field = matchstring(field,FIELD_NAMES.bias);
    if ~isempty(nnstring.first_match(field,{'size'}))
      nnerr.throw('Property',['"net.biases{i}.' field '" is a read only property.'])
    end
    for i=sub1
      if ~isempty(net.biases{i})
        switch(field)
        case 'initFcn'
          [initFcn,err] = nsubsasn(net.biases{i}.initFcn,subscripts,v);
          if isempty(err), [net,err] = setBiasInitFcn(net,i,initFcn); end
        case 'learn'
          [learn,err] = nsubsasn(net.biases{i}.learn,subscripts,v);
          if isempty(err), [net,err] = setBiasLearn(net,i,learn); end
        case 'learnFcn'
          [learnFcn,err] = nsubsasn(net.biases{i}.learnFcn,subscripts,v);
          if isempty(err), [net,err] = setBiasLearnFcn(net,i,learnFcn); end
        case 'learnParam'
          [learnParam,err] = nsubsasn(net.biases{i}.learnParam,subscripts,v);
          if isempty(err), [net,err] = setBiasLearnParam(net,i,learnParam); end
        case 'userdata'
          [net.biases{i}.userdata,err] = nsubsasn(net.biases{i}.userdata,subscripts,v);
        otherwise,
          error(message('nnet:Math:NonexistentField'))
        end
      end
    end

  % Input weights
  case 'inputWeights',
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'.')
      [net,err] = nsubasgn_cellfield(net,field,subs,v,subscripts);
      if ~isempty(err),nnerr.throw('Property',err); end
      return
    end
    if strcmp(type,'.'), error(message('nnet:Math:CantAssignFieldToNonStruct')), end
    if strcmp(type,'()'), error(message('nnet:Math:CantAssignDoubleAsCell')), end
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [sub1,sub2,err] = subs2(subs,[net.numLayers net.numInputs]);
    if ~isempty(err), nnerr.throw('Property',err), end

    [subscripts,field,type] = nextsubs(subscripts);
    if strcmp(type,'{}'),error(message('nnet:Math:CantAssignNonCellAsCell')),end
    if strcmp(type,'()'),error(message('nnet:Math:CantAssignArrayAsNonArray')),end
    
    field = matchstring(field,FIELD_NAMES.weight);
    if ~isempty(nnstring.first_match(field,{'size','initSettings'}))
      nnerr.throw('Property',['"net.inputWeights{i}.' field '" is a read only property.'])
    end
    for k=1:length(sub1)
      i = sub1(k);
      j = sub2(k);
      if ~isempty(net.inputWeights{i,j})
        switch(field)
        case 'delays'
          [delays,err] = nsubsasn(net.inputWeights{i,j}.delays,subscripts,v);
          if isempty(err), [net,err] = setInputWeightDelays(net,i,j,delays); end
        case 'initFcn'
          [initFcn,err] = nsubsasn(net.inputWeights{i,j}.initFcn,subscripts,v);
          if isempty(err), [net,err] = setInputWeightInitFcn(net,i,j,initFcn); end
        case 'learn'
          [learn,err] = nsubsasn(net.inputWeights{i,j}.learn,subscripts,v);
          if isempty(err), [net,err] = setInputWeightLearn(net,i,j,learn); end
        case 'learnFcn'
          [learnFcn,err] = nsubsasn(net.inputWeights{i,j}.learnFcn,subscripts,v);
          if isempty(err), [net,err] = setInputWeightLearnFcn(net,i,j,learnFcn); end
        case 'learnParam'
          [learnParam,err] = nsubsasn(net.inputWeights{i,j}.learnParam,subscripts,v);
          if isempty(err), [net,err] = setInputWeightLearnParam(net,i,j,learnParam); end
        case 'userdata',
          [net.inputWeights{i,j}.userdata,err] = nsubsasn(net.inputWeights{i,j}.userdata,subscripts,v);
        case 'weightFcn'
          [weightFcn,err] = nsubsasn(net.inputWeights{i,j}.weightFcn,subscripts,v);
          if isempty(err), [net,err] = setInputWeightWeightFcn(net,i,j,weightFcn); end
        case 'weightParam'
          [weightParam,err] = nsubsasn(net.inputWeights{i,j}.weightParam,subscripts,v);
          if isempty(err), [net,err] = setInputWeightWeightParam(net,i,j,weightParam); end
        otherwise,
          error(message('nnet:Math:NonexistentField'))
        end
      end
    end

  % Layer weights
  case 'layerWeights',
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'.')
      [net,err] = nsubasgn_cellfield(net,field,subs,v,subscripts);
      if ~isempty(err),nnerr.throw('Property',err); end
      return
    end
    if strcmp(type,'.'), error(message('nnet:Math:CantAssignFieldToNonStruct')), end
    if strcmp(type,'()'), error(message('nnet:Math:CantAssignDoubleAsCell')), end
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [sub1,sub2,err] = subs2(subs,[net.numLayers net.numLayers]);
    if ~isempty(err), nnerr.throw('Property',err), end

    [subscripts,field,type] = nextsubs(subscripts);
    if strcmp(type,'{}'),error(message('nnet:Math:CantAssignNonCellAsCell')),end
    if strcmp(type,'()'),error(message('nnet:Math:CantAssignArrayAsNonArray')),end
    
    field = matchstring(field,FIELD_NAMES.weight);
    if ~isempty(nnstring.first_match(field,{'size'}))
      nnerr.throw('Property',['"net.layerWeights{i}.' field '" is a read only property.'])
    end
    for k=1:length(sub1)
      i = sub1(k);
      j = sub2(k);
      if ~isempty(net.layerWeights{i,j})
        switch(field)
        case 'delays'
          [delays,err] = nsubsasn(net.layerWeights{i,j}.delays,subscripts,v);
          if isempty(err), [net,err] = setLayerWeightDelays(net,i,j,delays); end
        case 'initFcn'
          [initFcn,err] = nsubsasn(net.layerWeights{i,j}.initFcn,subscripts,v);
          if isempty(err), [net,err] = setLayerWeightInitFcn(net,i,j,initFcn); end
        case 'learn'
          [learn,err] = nsubsasn(net.layerWeights{i,j}.learn,subscripts,v);
          if isempty(err), [net,err] = setLayerWeightLearn(net,i,j,learn); end
        case 'learnFcn'
          [learnFcn,err] = nsubsasn(net.layerWeights{i,j}.learnFcn,subscripts,v);
          if isempty(err), [net,err] = setLayerWeightLearnFcn(net,i,j,learnFcn); end
        case 'learnParam'
          [learnParam,err] = nsubsasn(net.layerWeights{i,j}.learnParam,subscripts,v);
          if isempty(err), [net,err] = setLayerWeightLearnParam(net,i,j,learnParam); end
        case 'userdata',
          [net.layerWeights{i,j}.userdata,err] = nsubsasn(net.layerWeights{i,j}.userdata,subscripts,v);
        case 'weightFcn'
          [weightFcn,err] = nsubsasn(net.layerWeights{i,j}.weightFcn,subscripts,v);
          if isempty(err), [net,err] = setLayerWeightWeightFcn(net,i,j,weightFcn); end
        case 'weightParam'
          [weightParam,err] = nsubsasn(net.layerWeights{i,j}.weightParam,subscripts,v);
          if isempty(err), [net,err] = setLayerWeightWeightParam(net,i,j,weightParam); end
        otherwise,
          error(message('nnet:Math:NonexistentField'))
        end
      end
    end  
  
  % Outputs
  case {'outputs','targets'}
    
    % NNET 5.0 compatibility
    if strcmpi(field,'targets')
      nnerr.obs_use(mfilename,'"targets" is obsolete.',...
      'Use "outputs" to set properties of outputs/targets.');
    end
    
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'.')
      [net,err] = nsubasgn_cellfield(net,field,subs,v,subscripts);
      if ~isempty(err),nnerr.throw('Property',err); end
      return
    end
    if strcmp(type,'.'), error(message('nnet:Math:CantAssignFieldToNonStruct')), end
    if strcmp(type,'()'), error(message('nnet:Math:CantAssignDoubleAsCell')), end
    if ~moresubs, error(message('nnet:NNet:AssignSubObjectPropIndiv')), end
    [sub1,err] = subs1(subs,[1 net.numLayers]);
    if ~isempty(err), nnerr.throw('Property',err), end

    [subscripts,field,type] = nextsubs(subscripts);
    if strcmp(type,'{}'),error(message('nnet:Math:CantAssignNonCellAsCell')),end
    if strcmp(type,'()'),error(message('nnet:Math:CantAssignArrayAsNonArray')),end
    
    field = matchstring(field,FIELD_NAMES.output);
    
    % NNET 6.0 Compatibility
    if ~isempty(nnstring.first_match(field,{'processSettings','processedSize','size'}))
      nnerr.throw('Property',['"net.outputs{i}.' field '" is a read only property.'])
    end
    for i=sub1
      if ~isempty(net.outputs{i})
        switch(field)
        case 'exampleOutput'
          [exampleOutput,err] = nsubsasn(net.outputs{i}.exampleOutput,subscripts,v);
          if isempty(err), [net,err] = setOutputExampleOutput(net,i,exampleOutput); end
        case 'range'
          [range,err] = nsubsasn(net.outputs{i}.range,subscripts,v);
          if isempty(err), [net,err] = setOutputRange(net,i,range); end
        case 'name'
          [name,err] = nsubsasn(net.outputs{i}.name,subscripts,v);
          if isempty(err), [net,err] = setOutputName(net,i,name); end
        case 'feedbackInput'
          [feedbackInput,err] = nsubsasn(net.outputs{i}.feedbackInput,subscripts,v);
          if isempty(err), [net,err] = setOutputFeedbackInput(net,i,feedbackInput); end
        case 'feedbackDelay'
          [feedbackDelay,err] = nsubsasn(net.outputs{i}.feedbackDelay,subscripts,v);
          if isempty(err), [net,err] = setOutputFeedbackDelay(net,i,feedbackDelay); end
        case 'feedbackMode'
          [feedbackMode,err] = nsubsasn(net.outputs{i}.feedbackMode,subscripts,v);
          if isempty(err), [net,err] = setOutputFeedbackMode(net,i,feedbackMode); end
        case 'processFcns'
          [processFcns,err] = nsubsasn(net.outputs{i}.processFcns,subscripts,v);
          if isempty(err), [net,err] = setOutputProcessFcns(net,i,processFcns); end
        case {'processParams','processParam'}
          [processParams,err] = nsubsasn(net.outputs{i}.processParams,subscripts,v);
          if isempty(err), [net,err] = setOutputProcessParam(net,i,processParams); end
        case 'userdata',
          [net.outputs{i}.userdata,err] = nsubsasn(net.outputs{i}.userdata,subscripts,v);
        otherwise,
          error(message('nnet:Math:NonexistentField'))
        end
      end
    end
    
  % Network functions and parameters
  case 'adaptFcn',
    [adaptFcn,err] = nsubsasn(net.adaptFcn,subscripts,v);
    if isempty(err), [net,err]=setAdaptFcn(net,adaptFcn); end
  case 'adaptParam',
    [adaptParam,err] = nsubsasn(net.adaptParam,subscripts,v);
    if ~isempty(err), [net,err]=setAdaptParam(net,adaptParam); end
  case 'divideFcn',
    [divideFcn,err] = nsubsasn(net.divideFcn,subscripts,v);
    if isempty(err), [net,err]=setDivideFcn(net,divideFcn); end
  case 'divideParam',
    [divideParam,err] = nsubsasn(net.divideParam,subscripts,v);
    if isempty(err), [net,err]=setDivideParam(net,divideParam); end
  case 'divideMode',
    [divideMode,err] = nsubsasn(net.divideMode,subscripts,v);
    if isempty(err)
      divideMode = nntype.data_division_mode('format',divideMode,newValueName(netname,'.divideMode'));
      if isempty(err), net.divideMode = divideMode; end
    end
  case 'initFcn',
    [initFcn,err] = nsubsasn(net.initFcn,subscripts,v);
    if isempty(err), [net,err]=setInitFcn(net,initFcn); end
  case 'performFcn',
    [performFcn,err] = nsubsasn(net.performFcn,subscripts,v);
    if isempty(err), [net,err]=setPerformFcn(net,performFcn); end
  case 'performParam',
    [performParam,err] = nsubsasn(net.performParam,subscripts,v);
    if isempty(err), [net,err]=setPerformParam(net,performParam); end
  case 'plotFcns'
    [plotFcns,err] = nsubsasn(net.plotFcns,subscripts,v);
    if isempty(err), [net,err] = setPlotFcns(net,plotFcns); end
  case {'plotParam','plotParams'}
    [plotParams,err] = nsubsasn(net.plotParams,subscripts,v);
    if isempty(err), [net,err] = setPlotParams(net,plotParams); end
  case 'derivFcn',
    [derivFcn,err] = nsubsasn(net.derivFcn,subscripts,v);
    if isempty(err), [net,err]=setDerivFcn(net,derivFcn); end
  case 'trainFcn',
    [trainFcn,err] = nsubsasn(net.trainFcn,subscripts,v);
    if isempty(err), [net,err]=setTrainFcn(net,trainFcn); end
  case 'trainParam',
    [trainParam,err] = nsubsasn(net.trainParam,subscripts,v);
    if isempty(err), [net,err]=setTrainParam(net,trainParam); end
  
  % Weight and bias values
  case 'IW'
    [IW,err] = nsubsasn(net.IW,subscripts,v);
    if isempty(err), [net,err] = setiw(net,IW); end
  case 'LW'
    [LW,err] = nsubsasn(net.LW,subscripts,v);
    if isempty(err), [net,err] = setlw(net,LW); end
  case 'b'
    [B,err] = nsubsasn(net.b,subscripts,v);
    if isempty(err), [net,err] = setb(net,B); end
  
  % other
  case 'name',
    [name,err] = nsubsasn(net.name,subscripts,v);
    if isempty(err), [net,err]=setName(net,name); end
  case 'efficiency',
    % TODO - better checking
    [net.efficiency,err] = nsubsasn(net.efficiency,subscripts,v);
  case 'userdata',
    [net.userdata,err] = nsubsasn(net.userdata,subscripts,v);
      
  % NNET 6.0 Compatibility
  case 'gradientFcn',
    warning('nnet:Obsolete:gradientFcn',['The ''gradientFcn'' property is obsolete. ' ...
      'Use ''derivFcn'' instead.']);
    [gradientFcn,err] = nsubsasn(net.gradientFcn,subscripts,v);
    if ~isempty(err), nnerr.throw('Property',err), end
    [net,err]=setGradientFcn(net,gradientFcn);
    if isempty(gradientFcn)
     net.derivFcn = '';
    else
      derivFcn = '';
      switch gradientFcn
        case {'gdefaults'}, derivFcn = 'defaultderiv';
        case {'calcgbtt','calcjxbt'}, derivFcn = 'bttderiv';
        case {'calcgxfp''calcjxfp'}, derivFcn = 'fpderiv';
        case {'nnprop.grad','calcjx'}, derivFcn = 'staticderiv';
      end
      if isempty(derivFcn)
        disp('Unrecognized gradient function. Property ''derivFcn'' set to ''defaultderiv''.');
        net.derivFcn = 'defaultderiv';
      else
        disp(['Property ''propagateFcn'' set to ''' derivFcn '''.']);
        net.derivFcn = derivFcn;
      end
    end
  case 'gradientParam',
    warning(message('nnet:subsasgn:Obsolete'));
    [gradientParam,err] = nsubsasn(net.gradientParam,subscripts,v);
    if ~isempty(err), nnerr.throw('Property',err), end
    [net,err]=setGradientParam(net,gradientParam);
    
  % No such field
  otherwise, nnerr.throw('Reference',['Reference to non-existent field ''' field '''.']);
  end
  
case '{}',error(message('nnet:Math:CantAssignNonCellAsCell'))
case '()',error(message('nnet:Math:CantAssignArrayAsNonArray'))
end

% Error message
if ~isempty(err)
  err = nnerr.value(err,netname);
  nnerr.throw('Property',err)
end

net = nn_update_read_only(net);

% Convert Struct back to Object
net = network(net);

% ===========================================================
function n = newValueName(netname,suffix)

n = ['Value for ' netname suffix];

% ===========================================================
%% NAME
% ===========================================================
function [net,err] = setName(net,name)

[name,err] = nntype.string('format',name,'VALUE.name');
if ~isempty(err), return, end

net.name = name;
% ===========================================================
%% WEIGHT AND BIAS VALUES
% ===========================================================
function [net,err] = setiw(net,IW)

err = '';

if ~isa(IW,'cell')
  err = sprintf('net.IW must be a %g-by-%g cell array.',net.numLayers,net.numInputs);
  return
end
if any(size(IW) ~= [net.numLayers net.numInputs])
  err = sprintf('net.IW must be a %g-by-%g cell array.',net.numLayers,net.numInputs);
  return
end
for i=1:net.numLayers
  for j=1:net.numInputs
    if ~isa(IW{i,j},'double')
      if (net.inputConnect(i,j))
        err = sprintf('net.IW{%g,%g} must be a %g-by-%g matrix.',i,j,net.inputWeights{i,j}.size);
        return
      else
        err = sprintf('net.IW{%g,%g} must be an empty matrix.',i,j,net.inputWeights{i,j}.size);
        return
      end
    end
    if net.inputConnect(i,j)
      if any(size(IW{i,j}) ~= net.inputWeights{i,j}.size)
        err = sprintf('net.IW{%g,%g} must be a %g-by-%g matrix.',i,j,net.inputWeights{i,j}.size);
        return
      end
      net.IW{i,j} = IW{i,j};
    else
      if numel(IW{i,j}) ~= 0
        err = sprintf('net.IW{%g,%g} must be an empty matrix.',i,j);
        return
      end
    end
  end
end

% ===========================================================
function [net,err] = setlw(net,LW)

err = '';

if ~isa(LW,'cell')
  err = sprintf('net.LW must be a %g-by-%g cell array.',net.numLayers,net.numLayers);
  return
end
if any(size(LW) ~= [net.numLayers net.numLayers])
  err = sprintf('net.LW must be a %g-by-%g cell array.',net.numLayers,net.numLayers);
  return
end
for i=1:net.numLayers
  for j=1:net.numLayers
    if ~isa(LW{i,j},'double') && ~islogical(LW{i,j})
      if (net.layerConnect(i,j))
        err = sprintf('net.LW{%g,%g} must be a %g-by-%g matrix.',i,j,net.layerWeights{i,j}.size);
    return
      else
        err = sprintf('net.LW{%g,%g} must be an empty matrix.',i,j,net.layerWeights{i,j}.size);
    return
      end
    end
    if net.layerConnect(i,j)
      if any(size(LW{i,j}) ~= net.layerWeights{i,j}.size)
        err = sprintf('net.LW{%g,%g} must be a %g-by-%g matrix.',i,j,net.layerWeights{i,j}.size);
        return
      end
      net.LW{i,j} = LW{i,j};
    else
      if ~isempty(LW{i,j})
        err = sprintf('net.LW{%g,%g} must be an empty matrix.',i,j);
        return
      end
    end
  end
end

% ===========================================================
function [net,err] = setb(net,B)

err = '';

if ~isa(B,'cell')
  err = sprintf('net.b must be a %g-by-1 cell array.',net.numLayers);
  return
end
if any(size(B) ~= [net.numLayers 1])
  err = sprintf('net.b must be a %g-by-1 cell array.',net.numLayers);
  return
end
for i=1:net.numLayers
    if ~isa(B{i},'double')
      if (net.biasConnect(i))
        err = sprintf('net.b{%g} must be a %g-by-1 matrix.',i,net.biases{i}.size);
    return
      else
        err = sprintf('net.b{%g} must be an empty matrix.',i,net.biases{i}.size);
    return
      end
    end
    if net.biasConnect(i)
      if any(size(B{i}) ~= [net.biases{i}.size 1])
        err = sprintf('net.b{%g} must be a %g-by-1 matrix.',i,net.biases{i}.size);
        return
      end
      net.b{i} = B{i};
    else
      if ~isempty(B{i})
        err = sprintf('net.b{%g} must be an empty matrix.',i);
        return
      end
    end
end

% ===========================================================
%% ARCHITECTURE
% ===========================================================
function [net,err] = setNumInputs(net,numInputs)

% Checks
err = '';
if ~isposint(numInputs)
  err = '"numInputs" must be a positive integer or zero.';
  return
end

% Changes
if (numInputs < net.numInputs)
  keep = 1:numInputs;
  net.inputs = net.inputs(keep,1);
  net.inputConnect = net.inputConnect(:,keep);
  net.inputWeights = net.inputWeights(:,keep);
  net.IW = net.IW(:,keep);
elseif (numInputs > net.numInputs)
  extend = numInputs - net.numInputs;
  net.inputs = [net.inputs; repmat({nn_new_input_struct},extend,1)];
  net.inputConnect = logical([net.inputConnect zeros(net.numLayers,extend)]);
  net.inputWeights = [net.inputWeights cell(net.numLayers,extend)];
  net.IW = [net.IW cell(net.numLayers,extend)];
end
net.numInputs = numInputs;

% ===========================================================
function [net,err] = setNumLayers(net,numLayers)

% Checks
err = '';
if ~isposint(numLayers)
  err = '"numLayers" must be a positive integer or zero.';
  return
end

% Changes
if (numLayers < net.numLayers)
  keep = 1:numLayers;
  net.layers = net.layers(keep,1);
  net.biasConnect = net.biasConnect(keep,1);
  net.inputConnect = net.inputConnect(keep,:);
  net.layerConnect = net.layerConnect(keep,keep);
  net.outputConnect = net.outputConnect(1,keep);
  net.biases = net.biases(keep,1);
  net.inputWeights = net.inputWeights(keep,:);
  net.layerWeights = net.layerWeights(keep,keep);
  net.outputs = net.outputs(1,keep);
  net.b = net.b(1:numLayers,1);
  net.IW = net.IW(keep,:);
  net.LW = net.LW(keep,keep);
elseif (numLayers > net.numLayers)
  extend = numLayers-net.numLayers;
  net.layers = [net.layers; repmat({newLayer},extend,1)];
  net.biasConnect = [net.biasConnect; false(extend,1)];
  net.inputConnect = [net.inputConnect; false(extend,net.numInputs)];
  net.layerConnect = [net.layerConnect false(net.numLayers,extend); ...
    false(extend,numLayers)];
  net.outputConnect = [net.outputConnect false(1,extend)];
  net.biases = [net.biases; cell(extend,1)];
  net.inputWeights = [net.inputWeights; cell(extend,net.numInputs)];
  net.layerWeights = [net.layerWeights cell(net.numLayers,extend); ...
    cell(extend,numLayers)];
  net.outputs = [net.outputs cell(1,extend)];
  net.b = [net.b; cell(extend,1)];
  net.IW = [net.IW; cell(extend,net.numInputs)];
  net.LW = [net.LW cell(net.numLayers,extend); cell(extend,numLayers)];
end
net.numLayers = numLayers;

% ===========================================================
function [net,err] = setSampleTime(net,sampleTime)

% Checks
err = nntype.strict_pos_scalar('check',sampleTime);
if ~isempty(err), err = nnerr.value(err,'VALUE.sampleTime'); return; end

% Changes
net.sampleTime = sampleTime;

% ===========================================================
function [net,err] = setBiasConnect(net,biasConnect)

% Avoid errors due to inconsistently sized empty matrices
err = '';
if isempty(biasConnect) && isempty(net.biasConnect)
  return;
end

% Check & Format
if ~isbool(biasConnect,net.numLayers,1);
  err = sprintf('"biasConnect" must be a %gx1 boolean matrix.',net.numLayers);
  return
end
biasConnect = logical(biasConnect);

% Changes
oldBiasConnect = net.biasConnect;
net.biasConnect = biasConnect;
for i = find(oldBiasConnect ~= biasConnect)'
  if biasConnect(i)
    net.biases{i} = newBias;
    net = nn_configure_bias(net,i);
  else
    net.biases{i} = [];
    net.b{i} = [];
  end
end

% ===========================================================
function [net,err] = setInputConnect(net,inputConnect)

% Avoid errors due to inconsistently sized empty matrices
err = '';
if isempty(inputConnect) && isempty(net.inputConnect)
  return;
end

% Check & Format
if ~isbool(inputConnect,net.numLayers,net.numInputs);
  err = sprintf('"inputConnect" must be a %gx%g boolean matrix.',net.numLayers,net.numInputs);
  return
end
inputConnect = logical(inputConnect);

% Changes
oldInputConnect = net.inputConnect;
net.inputConnect = inputConnect;
for i=1:net.numLayers
  for j = find(oldInputConnect(i,:) ~= inputConnect(i,:))
    if inputConnect(i,j)
      net.inputWeights{i,j} = newWeight;
      x = net.inputs{j}.exampleInput;
      if isempty(x)
        net = nn_configure_input_weight(net,i,j);
      else
        % NNET 6.0 Compatibility
        net = nn_configure_input_weight(net,i,j,x);
      end
    else
      net.inputWeights{i,j} = [];
      net.IW{i,j} = [];
    end
  end
end

% ===========================================================
function [net,err] = setLayerConnect(net,layerConnect)

% Avoid errors due to inconsistently sized empty matrices
err = '';
if isempty(layerConnect) && isempty(net.layerConnect)
  return;
end

% Checks
if ~isbool(layerConnect,net.numLayers,net.numLayers);
  err = sprintf('"layerConnect" must be a %gx%g boolean matrix.',net.numLayers,net.numLayers);
  return
end
layerConnect = logical(layerConnect);

% Changes
oldLayerConnect = net.layerConnect;
net.layerConnect = layerConnect;
for i=1:net.numLayers
  for j = find(oldLayerConnect(i,:) ~= layerConnect(i,:))
    if layerConnect(i,j)
      net.layerWeights{i,j} = newWeight;
      net = nn_configure_layer_weight(net,i,j);
    else
      net.layerWeights{i,j} = [];
      net.LW{i,j} = [];
    end
  end
end

% TODO - check for broken feedback

% ===========================================================
function [net,err] = setOutputConnect(net,outputConnect)

% Avoid errors due to inconsistently sized empty matrices
err = '';
if isempty(outputConnect) && isempty(net.outputConnect)
  return;
end

% Checks
if ~isbool(outputConnect,1,net.numLayers);
  err = sprintf('"outputConnect" must be a 1x%g boolean matrix.',net.numLayers);
  return
end
outputConnect = logical(outputConnect);

% Changes
oldOutputConnect = net.outputConnect;
net.outputConnect = outputConnect;
for i = find(oldOutputConnect ~= outputConnect)
  if outputConnect(i)
    net.outputs{i} = newOutput;
    net = nn_configure_output(net,i,net.layers{i}.range);
  else
    net.outputs{i} = [];
  end
end

% TODO - check for broken feedback

% ===========================================================
%% INPUT PROPERTIES
% ===========================================================

% NNET 6.0 Compatibility
function [net,err] = setInputExampleInput(net,j,exampleInput)

% Checks
err = '';
% TODO - Error checks

% Changes
net.inputs{j}.exampleInput = exampleInput;
net = nn_configure_input(net,j,exampleInput);

% Feedback
fbindex = net.inputs{j}.feedbackOutput;
if ~isempty(fbindex)
  net.outputs{fbindex}.exampleOutput = exampleInput;
  net = nn_configure_output(net,fbindex,exampleInput);
end

% ===========================================================
function [net,err] = setInputName(net,i,name)

% Checks
[name,err] = nntype.string('format',name);
if ~isempty(err), err = nnerr.value(err,['New VALUE.inputs{' num2str(i) '}.name value']); return; end

% Changes
net.inputs{i}.name = name;

% Feedback
fbindex = net.inputs{i}.feedbackOutput;
if ~isempty(fbindex)
  net.outputs{fbindex}.name = name;
end

% ===========================================================
function [net,err] = setInputProcessFcns(net,j,processFcns)

% Checks
err = '';
if (~iscell(processFcns)) || (size(processFcns,1) > 1)
  err = sprintf('"inputs{%g}.processFcns" must be a row cell array of processing function names.',j);
  return
end
numFcns = size(processFcns,2);
for i=1:numFcns
  ithFcn = processFcns{i};
  if ~ischar(ithFcn) || (size(ithFcn,1) ~= 1) || (size(ithFcn,2) < 1)
    err = sprintf('"inputs{%g}.processFcns{%g}" must be a string name for a processing function.',j,i);
    return
  end
end
if isempty(processFcns), processFcns = cell(1,0); end

% Changes
net.inputs{j}.processFcns = processFcns;
net.inputs{j}.processParams = getDefaultParam(processFcns);
net = nn_configure_input(net,j,net.inputs{j}.exampleInput);

% Feedback
fbindex = net.inputs{j}.feedbackOutput;
if ~isempty(fbindex)
  net.outputs{fbindex}.processFcns = processFcns;
  net.outputs{fbindex}.processParams = getDefaultParam(processFcns);
  net = nn_configure_output(net,fbindex,net.inputs{j}.exampleInput);
end

% ===========================================================
function [net,err] = setInputProcessParam(net,j,processParams)

% Checks
err = '';
if ~iscell(processParams) || (size(processParams,1) > 1)
  err = sprintf('"inputs{%g}.processParams must be a row cell array of structures.',j);
  return
end
processFcns = net.inputs{j}.processFcns;
numProcess = length(processFcns);
if length(processParams) ~= numProcess
  err = sprintf('"inputs{%g}.processParams must have same number of elements as processFcns.',j);
  return
end
for n=1:length(processParams)
  processFcn = net.inputs{j}.processFcns{n};
  functionInfo = feval(processFcn,'info');
  err = nntest.param(functionInfo.parameterInfo,processParams{n});
  if ~isempty(err)
    err = nnerr.value(err,['net.inputs{' num2str(j) '}.processParams{' num2str(n) '}']);
    return;
  end
end
if isempty(processParams), processParams = cell(1,0); end

% Changes
net.inputs{j}.processParams = processParams;
net = nn_configure_input(net,j,net.inputs{j}.exampleInput);

% Feedback
fbindex = net.inputs{j}.feedbackOutput;
if ~isempty(fbindex)
  net.outputs{fbindex}.processParams = processParams;
  net = nn_configure_output(net,fbindex,net.inputs{j}.exampleInput);
end

% ===========================================================
function [net,err] = setInputRange(net,j,range)

% Checks
err = '';
if ~isrealmat(range,NaN,2)
  err = sprintf('"inputs{%g}.range" must an Rx2 real matrix.',j);
  return
end
if any(range(:,1) > range(:,2))
  err = sprintf('First column elements in "inputs{%g}.range" must be smaller than the second.',j);
  return
end

% Changes
net = nn_configure_input(net,j,range);

% Feedback
fbindex = net.inputs{j}.feedbackOutput;
if ~isempty(fbindex)
  net = nn_configure_output(net,fbindex,range);
end

% ===========================================================
function [net,err] = setInputSize(net,j,newSize)

% Checks
err = '';
if ~isposint(newSize)
  err = sprintf('"inputs{%g}.size" must be a positive integer.',j);
  return
end

range = repmat([-inf inf],newSize,1);
net = setInputRange(net,j,range);

% ===========================================================
%% LAYER PROPERTIES
% ===========================================================

function [net,err] = setLayerDimensions(net,i,newDimensions)

% Checks
err = '';
if ~isa(newDimensions,'double')
  err = sprintf('"layers{%g}.dimensions" must be an integer row vector.',i);
  return
end
if size(newDimensions,1) ~= 1
  err = sprintf('"layers{%g}.dimensions" must be an integer row vector.',i);
  return
end
if any(newDimensions ~= floor(newDimensions))
  err = sprintf('"layers{%g}.dimensions" must be an integer row vector.',i);
  return
end

% Flag
sizeChange = prod(newDimensions) ~= net.layers{i}.size;

% Changes
net = nn_configure_layer(net,i,newDimensions);

% Feedback
if sizeChange && net.outputConnect(i)
  fbindex = net.outputs{i}.feedbackInput;
  if ~isempty(fbindex)
    x = net.outputs{i}.exampleOutput;
    if isempty(x), x = net.outputs{i}.range; end
    net = nn_configure_input(net,fbindex,x);
  end
end

% ===========================================================

function [net,err] = setLayerDistanceFcn(net,i,distanceFcn)

% Checks
err = '';
if ~ischar(distanceFcn)
  err = sprintf('"layers{%g}.distanceFcn" must be the name of a distance function or ''''.',i);
  return
end
if ~isempty(distanceFcn)
  if ~exist(distanceFcn,'file')
    err = sprintf('"layers{%g}.distanceFcn" cannot be set to non-existing function "%s".',i,distanceFcn);
    return
  end
end

% Changes
net.layers{i}.distanceFcn = distanceFcn;
net.layers{i}.distanceParam = getDefaultParam(distanceFcn);
net = nn_configure_layer(net,i,net.layers{i}.dimensions);

% ===========================================================

function [net,err] = setLayerDistanceParam(net,i,distanceParam)

% Checks
if isempty(distanceParam),distanceParam = struct; end
functionInfo = feval(net.layers{i}.distanceFcn,'info');
err = nntest.param(functionInfo.parameterInfo,distanceParam);
if ~isempty(err)
  err = nnerr.value(err,['net.layers{' num2str(i) '}.netInputParam']);
  return;
end

% Changes
net.layers{i}.distanceParam = distanceParam;
net = nn_configure_layer(net,i,net.layers{i}.dimensions);

% ===========================================================

function [net,err] = setLayerInitFcn(net,i,initFcn)

% Checks
err = '';
if ~ischar(initFcn)
  err = sprintf('"layers{%g}.initFcn" must be '''' or the name of a bias initialization function.',i);
  return
end
if ~isempty(initFcn) && ~exist(initFcn,'file')
  err = sprintf('"layers{%g}.initFcn" cannot be set to non-existing function "%s".',i,initFcn);
  return
end

% Changes
net.layers{i}.initFcn = initFcn;
net = nn_configure_layer(net,i,net.layers{i}.dimensions);

% ===========================================================
function [net,err] = setLayerName(net,i,name)

% Checks
[name,err] = nntype.string('format',name);
if ~isempty(err), err = nnerr.value(err,['New VALUE.layers{' num2str(i) '}.name value']); return; end

% Changes
net.layers{i}.name = name;

% ===========================================================
function [net,err] = setLayerNetInputFcn(net,i,netInputFcn)

% Checks
err = nntype.string('check',netInputFcn);
if ~isempty(err)
  err = nnerr.value(err,['layers{' num2str(i) '}.netInputFcn value']);
  return;
end

% Changes
net.layers{i}.netInputFcn = netInputFcn;
net.layers{i}.netInputParam = getDefaultParam(netInputFcn);

% ===========================================================

function [net,err] = setLayerNetInputParam(net,i,netInputParam)

% Checks
if isempty(netInputParam),netInputParam = struct; end
functionInfo = feval(net.layers{i}.netInputFcn,'info');
err = nntest.param(functionInfo.parameterInfo,netInputParam);
if ~isempty(err)
  err = nnerr.value(err,['net.layers{' num2str(i) '}.netInputParam']);
  return;
end

% Changes
net.layers{i}.netInputParam = netInputParam;

% ===========================================================
function [net,err] = setLayerSize(net,i,newSize)

% Checks
err = '';
if ~isposint(newSize)
  err = sprintf('"layers{%g}.size" must be a positive integer.',ind);
  return
end

% Changes
net = setLayerDimensions(net,i,newSize);

% ===========================================================
function [net,err] = setLayerTopologyFcn(net,i,topologyFcn)

% Checks
err = '';
if ~ischar(topologyFcn)
  err = sprintf('"layers{%g}.topologyFcn" must be the name of a topology function.',i);
  return
end
if ~exist(topologyFcn,'file')
  err = sprintf('"layers{%g}.topologyFcn" cannot be set to non-existing function "%s".',i,topologyFcn);
  return
end

% Changes
net.layers{i}.topologyFcn = topologyFcn;
net = nn_configure_layer(net,i,net.layers{i}.dimensions);

% ===========================================================
function [net,err] = setLayerTransferFcn(net,i,transferFcn)

% Checks
err = '';
if ~ischar(transferFcn)
  err = sprintf('"layers{%g}.transferFcn" must be the name of a transfer function.',i);
  return
end

% Changes
net.layers{i}.transferFcn = transferFcn;
net.layers{i}.transferParam = getDefaultParam(transferFcn);
net.layers{i}.range = repmat(feval(net.layers{i}.transferFcn, ...
  'outputRange'),net.layers{i}.size,1);
net = nn_configure_layer(net,i,net.layers{i}.dimensions);

% ===========================================================

function [net,err] = setLayerTransferParam(net,i,transferParam)

% Checks
if isempty(transferParam), transferParam = struct; end
functionInfo = feval(net.layers{i}.transferFcn,'info');
err = nntest.param(functionInfo.parameterInfo,transferParam);
if ~isempty(err)
  err = nnerr.value(err,['net.layers{' num2str(i) '}.transferParam']);
  return;
end

% Changes
net.layers{i}.transferParam = transferParam;
net.layers{i}.range = repmat(feval(net.layers{i}.transferFcn, ...
  'outputRange'),newSize,1);
net = nn_configure_layer(net,i,net.layers{i}.dimensions);

% ===========================================================
%% OUTPUT PROPERTIES
% ===========================================================

% NNET 6.0 Compatibility
function [net,err] = setOutputExampleOutput(net,j,exampleOutput)

% Checks
err = '';
if islogical(exampleOutput), exampleOutput = double(exampleOutput); end
% TODO - error/formatting

% Changes
net.outputs{j}.exampleOutput = exampleOutput;
net = nn_configure_output(net,j,exampleOutput);

% Feedback
fbindex = net.outputs{j}.feedbackInput;
if ~isempty(fbindex)
  net.inputs{fbindex}.exampleInput = exampleInput;
  net = nn_configure_output(net,fbindex,exampleInput);
end

% ===========================================================
function [net,err] = setOutputName(net,i,name)

% Checks
[name,err] = nntype.string('format',name);
if ~isempty(err), err = nnerr.value(err,['New VALUE.outputs{' num2str(i) '}.name value']); return; end

% Changes
net.outputs{i}.name = name;

% Feedback
fbindex = net.outputs{i}.feedbackInput;
if ~isempty(fbindex)
  net.inputs{fbindex}.name = name;
end

% ===========================================================
function [net,err] = setOutputFeedbackInput(net,i,index)

err = '';
if isempty(index)
  if strcmp(net.outputs{i}.feedbackMode,'open')
    net = nn_feedback_open2closed(net,i);
  end
  return
end

err = nntype.strict_pos_int_scalar('check',index);
if ~isempty(err)
  err = nnerr.value(err,['Value for VALUE.outputs{' num2str(i) '}.feedbackInput']);
  return;
end
if index > (net.numInputs + 1)
  err = ['Value for VALUE.outputs{' num2str(i) ...
    '}.feedbackInput is more than 1 greater than number of indexs.'];
  return;
end

if net.outputs{i}.feedbackInput == index
  return;
end

switch net.outputs{i}.feedbackMode
  case ''
    net = nn_feedback_none2open(net,i,index);
  case 'open'
    net = nn_move_input(net,net.outputs{i}.feedbackInput,index);
  case 'closed'
    net = nn_feedback_closed2open(net,i,index);
end

% ===========================================================
function [net,err] = setOutputFeedbackDelay(net,i,delay)

[delay,err] = nntype.int_scalar('format',delay,'feedbackDelay');
if ~isempty(err), return; end  

net.outputs{i}.feedbackDelay = delay;

% ===========================================================
function [net,err] = setOutputFeedbackMode(net,i,mode)

[mode,err] = nntype.feedback_mode('format',mode,'feedbackMode');
if ~isempty(err), return; end

oldMode = net.outputs{i}.feedbackMode;
if ~strcmp(mode,oldMode)
  switch mode
    case 'none'
      switch oldMode
        case 'open', net = nn_feedback_open2none(net,i);
        case 'closed',net = nn_feedback_closed2none(net,i);
      end
    case 'open'
      switch oldMode
        case 'none', net = nn_feedback_none2open(net,i);
        case 'closed', net = nn_feedback_closed2open(net,i);
      end
    case 'closed'
      switch oldMode
        case 'none', net = nn_feedback_none2closed(net,i);
        case 'open', net = nn_feedback_open2closed(net,i);
      end
  end
end

% ===========================================================
function [net,err] = setOutputProcessFcns(net,j,processFcns)

% Checks
err = '';
if (~iscell(processFcns)) || (size(processFcns,1) > 1)
  err = sprintf('"outputs{%g}.processFcns" must be a row cell array of processing function names.',j);
  return
end
numFcns = size(processFcns,2);
for i=1:numFcns
  ithFcn = processFcns{i};
  if ~ischar(ithFcn) || (size(ithFcn,1) ~= 1) || (size(ithFcn,2) < 1)
    err = sprintf('"outputs{%g}.processFcns{%g}" must be a string name for a processing function.',j,i);
    return
  end
end
if isempty(processFcns), processFcns = cell(1,0); end

% Changes
net.outputs{j}.processFcns = processFcns;
net.outputs{j}.processParams = getDefaultParam(processFcns);
net = nn_configure_output(net,j,net.outputs{j}.exampleOutput);

% Feedback
fbindex = net.outputs{j}.feedbackInput;
if ~isempty(fbindex)
  net.inputs{fbindex}.processFcns = processFcns;
  net.inputs{fbindex}.processParams = getDefaultParam(processFcns);
  net = nn_configure_input(net,fbindex,net.outputs{j}.exampleOutput);
end

% ===========================================================
function [net,err] = setOutputProcessParam(net,j,processParams)

% Checks
err = '';
if ~iscell(processParams) || (size(processParams,1) > 1)
  err = sprintf('"inputs{%g}.processParams must be a row cell array of structures.',j);
  return
end
processFcns = net.outputs{j}.processFcns;
numProcess = length(processFcns);
if length(processParams) ~= numProcess
  err = sprintf('"outputs{%g}.processParams does not have same length as processFcns.',j);
  return;
end
for i=1:numProcess
  if isempty(processParams{i}), processParams{i} = struct; end
end
for n=1:length(processParams)
  processFcn = net.outputs{j}.processFcns{n};
  functionInfo = feval(processFcn,'info');
  err = nntest.param(functionInfo.parameterInfo,processParams{n});
  if ~isempty(err)
    err = nnerr.value(err,['net.outputs{' num2str(j) '}.processParams{' num2str(n) '}']);
    return;
  end
end
if isempty(processParams), processParams = cell(1,0); end

% Changes
net.outputs{j}.processParams = processParams;
net = nn_configure_output(net,j,net.outputs{j}.exampleOutput);

% Feedback
fbindex = net.outputs{j}.feedbackInput;
if ~isempty(fbindex)
  net.inputs{fbindex}.processParams = processParams;
  net = nn_configure_input(net,fbindex,net.outputs{j}.exampleOutput);
end

% ===========================================================

function [net,err] = setOutputRange(net,j,range)

% Checks
err = '';
if ~isnumeric(range)
  err = ['VALUE.outputs{' num2str(j) '}.range must be numeric.'];
  return
elseif ndims(range) ~= 2
  err = ['VALUE.outputs{' num2str(j) '}.range must be two dimensional.'];
  return
elseif size(range,2) ~= 2
  err = ['VALUE.outputs{' num2str(j) '}.range must have two columns.'];
  return
end


% Changes
net.outputs{j}.exampleOutput = [];
net = nn_configure_output(net,j,range);

% Feedback
fbindex = net.outputs{j}.feedbackInput;
if ~isempty(fbindex)
  net.inputs{fbindex}.exampleInput = [];
  net = nn_configure_output(net,fbindex,range);
end

% ===========================================================
%% BIAS PROPERTIES
% ===========================================================

function [net,err] = setBiasInitFcn(net,i,initFcn)

% Checks
err = '';
if ~ischar(initFcn)
  err = sprintf('"biases{%g}.initFcn" must be '''' or the name of a bias initialization function.',i);
  return
end
if ~isempty(initFcn) && ~exist(initFcn,'file')
  err = sprintf('"biases{%g}.initFcn" cannot be set to non-existing function "%s".',i,initFcn);
  return
end

% Changes
net.biases{i}.initFcn = initFcn;

% ===========================================================

function [net,err] = setBiasLearn(net,i,learn)

% Checks
err = '';
if ~isbool(learn,1,1)
  err = sprintf('"biases{%g}.learn" must be 0 or 1.',i);
  return
end

% Changes
net.biases{i}.learn = learn;

% ===========================================================

function [net,err] = setBiasLearnFcn(net,i,learnFcn)

% Checks
err = '';
if ~ischar(learnFcn)
  err = sprintf('"biases{%g}.learnFcn" must be '''' or the name of a bias learning function.',i);
  return
end
if ~isempty(learnFcn) && ~exist(learnFcn,'file')
  err = sprintf('"biases{%g}.learnFcn" cannot be set to non-existing function "%s".',i,learnFcn);
  return
end

% Changes
net.biases{i}.learnFcn = learnFcn;
net.biases{i}.learnParam = getDefaultParam(learnFcn);

% ===========================================================

function [net,err] = setBiasLearnParam(net,i,learnParam)

% Checks
if isempty(learnParam), learnParam = struct; end
functionInfo = feval(net.biases{i}.learnFcn,'info');
err = nntest.param(functionInfo.parameters,learnParam);
if ~isempty(err)
  err=nnerr.value(err,['VALUE.biases{' num2str(i) '}.learnParam']);
  return;
end

% Changes
net.biases{i}.learnParam = learnParam;

% ===========================================================
%% INPUT WEIGHT PROPERTIES
% ===========================================================

function [net,err] = setInputWeightDelays(net,i,j,delays)

% Checks
[delays,err] = nntype.delayvec('format',delays);
if ~isempty(err)
  err = nnerr.value(err,['VALUE.inputWeights{' num2str(i) ',' num2str(j) '}.delays']);
  return;
end

% Changes
oldDelays = net.inputWeights{i,j}.delays;
net.inputWeights{i,j}.delays = delays;
if length(delays) ~= length(oldDelays)
  net = nn_configure_input_weight(net,i,j);
end

% ===========================================================

function [net,err] = setInputWeightInitFcn(net,i,j,initFcn)

% Checks
err = '';
if ~ischar(initFcn)
  err = sprintf('"inputWeights{%g,%g}.initFcn" must be '''' or the name of a weight initialization function.',i,j);
  return
end
if ~isempty(initFcn) && ~exist(initFcn,'file')
  err = sprintf('"inputWeights{%g,%g}.initFcn" cannot be set to non-existing function "%s".',i,j,initFcn);
  return
end

% Changes
net.inputWeights{i,j}.initFcn = initFcn;
net = nn_configure_input_weight(net,i,j);

% ===========================================================

function [net,err] = setInputWeightLearn(net,i,j,learn)

% Checks
err = '';
if ~isbool(learn,1,1)
  err = sprintf('"inputWeights{%g,%g}.learn" must be 0 or 1.',i,j);
  return
end

% Changes
net.inputWeights{i,j}.learn = learn;

% ===========================================================

function [net,err] = setInputWeightLearnFcn(net,i,j,learnFcn)

% Checks
err = '';
if ~ischar(learnFcn)
  err = sprintf('"inputWeights{%g,%g}.learnFcn" must be '''' or the name of a weight learning function.',i,j);
  return
end
if ~isempty(learnFcn) && ~exist(learnFcn,'file')
  err = sprintf('"inputWeights{%g,%g}.learnFcn" cannot be set to non-existing function "%s".',i,j,learnFcn);
  return
end

% Changes
net.inputWeights{i,j}.learnFcn = learnFcn;
net.inputWeights{i,j}.learnParam = getDefaultParam(learnFcn);

% ===========================================================

function [net,err] = setInputWeightLearnParam(net,i,j,learnParam)

% Checks
if isempty(learnParam), learnParam = struct; end
functionInfo = feval(net.inputWeights{i,j}.learnFcn,'info');
err = nntest.param(functionInfo.parameters,learnParam);
if ~isempty(err)
  err = nnerr.value(err,['VALUE.inputWeights{' num2str(i) '.' num2str(j) '}.learnParam']);
  return;
end

% Changes
net.inputWeights{i,j}.learnParam = learnParam;

% ===========================================================

function [net,err] = setInputWeightWeightFcn(net,i,j,weightFcn)

% Checks
err = '';
if ~ischar(weightFcn)
  err = sprintf('"inputWeights{%g,%g}.weightFcn" must be the name of a weight function.',i,j);
  return
end

% Changes
net.inputWeights{i,j}.weightFcn = weightFcn;
net.inputWeights{i,j}.weightParam = getDefaultParam(weightFcn);
net = nn_configure_input_weight(net,i,j);

% ===========================================================

function [net,err] = setInputWeightWeightParam(net,i,j,weightParam)

% Checks
if isempty(weightParam), weightParam = struct; end
functionInfo = feval(net.inputWeights{i,j}.weightFcn,'info');
err = nntest.param(functionInfo.parameterInfo,weightParam);
if ~isempty(err)
  err = nnerr.value(err,['net.inputWeights{' num2str(i) '.' num2str(j) '}.weightParam']);
  return;
end

% Changes
net.inputWeights{i,j}.weightParam = weightParam;
net = nn_configure_input_weight(net,i,j,[]);

% NNET 6.0 Compatibility
x = net.inputs{i}.exampleInput;
if ~isempty(x)
  net = nn_configure_input_weight(net,i,j,x);
end

% ===========================================================
%% LAYER WEIGHT PROPERTIES
% ===========================================================

function [net,err] = setLayerWeightDelays(net,i,j,delays)

% Checks
[delays,err] = nntype.delayvec('format',delays);
if ~isempty(err)
  err = nnerr.value(err,['VALUE.layerWeights{' num2str(i) ',' num2str(j) '}.delays']);
  return;
end

% Changes
oldDelays = net.layerWeights{i,j}.delays;
net.layerWeights{i,j}.delays = delays;
if length(delays) ~= length(oldDelays)
  net = nn_configure_layer_weight(net,i,j);
end

% ===========================================================

function [net,err] = setLayerWeightInitFcn(net,i,j,initFcn)

% Checks
err = '';
if ~ischar(initFcn)
  err = sprintf('"layerWeights{%g,%g}.initFcn" must be '''' or the name of a weight initialization function.',i,j);
  return
end
if ~isempty(initFcn) && ~exist(initFcn,'file')
  err = sprintf('"layerWeights{%g,%g}.initFcn" cannot be set to non-existing function "%s".',i,j,initFcn);
  return
end

% Changes
net.layerWeights{i,j}.initFcn = initFcn;
net = nn_configure_layer_weight(net,i,j);

% ===========================================================

function [net,err] = setLayerWeightLearn(net,i,j,learn)

% Checks
err = '';
if ~isbool(learn,1,1)
  err = sprintf('"layerWeights{%g,%g}.learn" must be 0 or 1.',i,j);
  return
end

% Changes
net.layerWeights{i,j}.learn = learn;

% ===========================================================

function [net,err] = setLayerWeightLearnFcn(net,i,j,learnFcn)

% Checks
err = '';
if ~ischar(learnFcn)
  err = sprintf('"layerWeights{%g,%g}.learnFcn" must be '''' or the name of a weight learning function.',i,j);
  return
end
if ~isempty(learnFcn) && ~exist(learnFcn,'file')
  err = sprintf('"layerWeights{%g,%g}.learnFcn" cannot be set to non-existing function "%s".',i,j,learnFcn);
  return
end

% Changes
net.layerWeights{i,j}.learnFcn = learnFcn;
net.layerWeights{i,j}.learnParam = getDefaultParam(learnFcn);

% ===========================================================

function [net,err] = setLayerWeightLearnParam(net,i,j,learnParam)

% Checks
if isempty(learnParam), learnParam = struct; end
functionInfo = feval(net.layerWeights{i,j}.learnFcn,'info');
err = nntest.param(functionInfo.parameters,learnParam);
if ~isempty(err)
  err = nnerr.value(err,['net.layerWeights{' num2str(i) '.' num2str(j) '}.learnParam']);
  return;
end

% Changes
net.layerWeights{i,j}.learnParam = learnParam;

% ===========================================================

function [net,err] = setLayerWeightWeightFcn(net,i,j,weightFcn)

% Checks
err = '';
if ~ischar(weightFcn)
  err = sprintf('"layerWeights{%g,%g}.weightFcn" must be the name of a weight function.',i,j);
  return
end

% Changes
net.layerWeights{i,j}.weightFcn = weightFcn;
net.layerWeights{i,j}.weightParam = getDefaultParam(weightFcn);
net = nn_configure_layer_weight(net,i,j);

% ===========================================================

function [net,err] = setLayerWeightWeightParam(net,i,j,weightParam)

% Checks
if isempty(weightParam), weightParam = struct; end
functionInfo = feval(net.layerWeights{i,j}.weightFcn,'info');
err = nntest.param(functionInfo.parameterInfo,weightParam);
if ~isempty(err)
  err = nnerr.value(err,['net.layerWeights{' num2str(i) '.' num2str(j) '}.weightParam']);
  return;
end

% Changes
net.layerWeights{i,j}.weightParam = weightParam;
net = nn_configure_layer_weight(net,i,j);
  
% ===========================================================
%% FUNCTIONS AND PARAMETERS
% ===========================================================

function [net,err] = setAdaptFcn(net,adaptFcn)

% Checks
err = '';
if ~ischar(adaptFcn)
  err = sprintf('"adaptFcn" must be '''' or the name of a network adapt function.');
  return
end
if strcmp(adaptFcn,'trains')
  disp('Notification: TRAINS is obsolete, adaptive function ADAPTWB will be used.');
  adaptFcn = 'adaptwb';
end
if ~isempty(adaptFcn) && ~exist(adaptFcn,'file')
  err = sprintf('"adaptFcn" cannot be set to non-existing function "%s".',adaptFcn);
  return
end

% Changes
net.adaptFcn = adaptFcn;
net.adaptParam = getDefaultParam(adaptFcn);

% ===========================================================
function [net,err] = setAdaptParam(net,adaptParam)

% Checks
if isempty(adaptParam), adaptParam = struct; end
functionInfo = feval(net.adaptFcn,'info');
err = nntest.param(functionInfo.parameters,adaptParam);
if ~isempty(err)
  err = nnerr.value(err,'net.adaptParam');
  return;
end

% Changes
net.adaptParam = adaptParam;

% ===========================================================
function [net,err] = setDivideFcn(net,divideFcn)

% Checks
err = '';
if ~ischar(divideFcn)
  err = sprintf('"divideFcn" must be '''' or the name of a data division function.');
  return
end
if ~isempty(divideFcn) && ~exist(divideFcn,'file')
  err = sprintf('"divideFcn" cannot be set to non-existing function "%s".',divideFcn);
  return
end

% Changes
net.divideFcn = divideFcn;
net.divideParam = getDefaultParam(divideFcn);

% ===========================================================
function [net,err] = setDivideParam(net,divideParam)

% Checks
if isempty(divideParam), divideParam = struct; end
functionInfo = feval(net.divideFcn,'info');
err = nntest.param(functionInfo.parameters,divideParam);
if ~isempty(err), err = nnerr.value(err,'VALUE.divideParam'); return; end

% Changes
net.divideParam = divideParam;

% ===========================================================
% NNT 5.1 Backward Compatibility
function [net,err] = setGradientFcn(net,gradientFcn)

% Checks
err = '';
if ~ischar(gradientFcn)
  err = sprintf('"gradientFcn" must be '''' or the name of a network adapt function.');
  return
end
if ~isempty(gradientFcn) && ~exist(gradientFcn,'file')
  err = sprintf('"gradientFcn" cannot be set to non-existing function "%s".',gradientFcn);
  return
end

% Changes
net.gradientFcn = gradientFcn;

% ===========================================================
% NNT 5.1 Backward Compatibility
function [net,err] = setGradientParam(net,gradientParam)

% Checks
err = '';

% Changes
net.gradientParam = gradientParam;

% ===========================================================

function [net,err] = setInitFcn(net,initFcn)

% Checks
err = '';
if ~ischar(initFcn)
  err = sprintf('"initFcn" must be '''' or the name of a network initialization function.');
  return
end
if ~isempty(initFcn) && ~exist(initFcn,'file')
  err = sprintf('"initFcn" cannot be set to non-existing function "%s".',initFcn);
  return
end

% Changes
net.initFcn = initFcn;

% ===========================================================

function [net,err] = setPerformFcn(net,performFcn)

% Checks
err = '';
if ~ischar(performFcn)
  err = sprintf('"performFcn" must be '''' or the name of a network performance function.');
  return
end
if ~isempty(nnstring.match(performFcn,{'msereg','mseregec','msne','msnereg'}))
  performFcn = 'mse';
end
if ~isempty(performFcn) && ~exist(performFcn,'file')
  err = sprintf('"performFcn" cannot be set to non-existing function "%s".',performFcn);
  return
end

% Changes
net.performFcn = performFcn;
net.performParam = getDefaultParam(performFcn);

% ===========================================================

function [net,err] = setPerformParam(net,performParam)

% Checks
if isempty(performParam), performParam = struct; end
functionInfo = feval(net.performFcn,'info');
err = nntest.param(functionInfo.parameterInfo,performParam);
if ~isempty(err), return; end

% Changes
net.performParam = performParam;

% ===========================================================

function [net,err] = setPlotFcns(net,plotFcns)

% Checks
err = '';
if ~iscell(plotFcns) || (size(plotFcns,1) > 1)
  err = sprintf('"plotFcns" must be a row cell array of plot function names.');
  return
end
for i=1:length(plotFcns)
  plotFcn = plotFcns{i};
  if ~ischar(plotFcn)
    err = sprintf('"plotFcns" must be a row cell array of plot function names.');
    return
  end
  if ~exist(plotFcn,'file')
    err = sprintf('"plotFcns" must be a row cell array of plot function names.');
    return
  end
end
if isempty(plotFcns), plotFcns = cell(1,0); end

% Changes
net.plotFcns = plotFcns;
net.plotParams = getDefaultParam(plotFcns);

% ===========================================================

function [net,err] = setPlotParams(net,plotParams)

% Checks
% Checks
err = '';
if ~iscell(plotParams) || (size(plotParams,1) > 1)
  err = '"net.plotParams must be a row cell array of nnetParam.';
  return
end
numFcns = length(net.plotFcns);
if length(plotParams) ~= numFcns
  err = '"net.plotParams must have the same number of elements as .plotFcns.';
  return
end
for n=1:numFcns
  functionInfo = feval(net.plotFcns{n},'info');
  err = nntest.param(functionInfo.parameters,plotParams{n});
  if ~isempty(err)
    err = nnerr.value(err,['net.plotParams{' num2str(n) '}']);
    return;
  end
end
if isempty(plotParams), plotParams = cell(1,0); end

% Changes
net.plotParams = plotParams;

% ===========================================================

function [net,err] = setDerivFcn(net,derivFcn)

% Checks
err = '';
if ~ischar(derivFcn)
  err = sprintf('"propagateFcn" must be '''' or the name of a network train function.');
  return
end
if ~isempty(derivFcn) && ~exist(derivFcn,'file')
  err = sprintf('"propagateFcn" cannot be set to non-existing function "%s".',propagateFcn);
  return
end
if isempty(derivFcn), derivFcn = 'defaultderiv'; end

% Changes
net.derivFcn = derivFcn;

% ===========================================================

function [net,err] = setTrainFcn(net,trainFcn)

% Checks
err = '';
if ~ischar(trainFcn)
  err = sprintf('"trainFcn" must be '''' or the name of a network train function.');
  return
end
if ~isempty(trainFcn) && ~exist(trainFcn,'file')
  err = sprintf('"trainFcn" cannot be set to non-existing function "%s".',trainFcn);
  return
end

% Changes
net.trainFcn = trainFcn;
net.trainParam = getDefaultParam(trainFcn);
   
 % NNET 6.0 Compatibility
if ~isempty(trainFcn)
   net.gradientFcn = feval(trainFcn,'gdefaults',net.numLayerDelays);
end

% ===========================================================

function [net,err] = setTrainParam(net,trainParam)

% Checks
if isempty(trainParam), trainParam = struct; end
functionInfo = feval(net.trainFcn,'info');
err = nntest.param(functionInfo.parameters,trainParam);
if ~isempty(err), err=nnerr.value(err,'VALUE.trainParam'); return; end

% Changes
net.trainParam = trainParam;

% ===========================================================
%% UTILITY FUNCTIONS
% ===========================================================

% ===========================================================
function param = getDefaultParam(fcn)
if ischar(fcn)
  if isempty(fcn)
    param = struct;
  else
    param = struct(feval(fcn,'defaultParam'));
  end
elseif iscell(fcn)
  numFcns = length(fcn);
  param = cell(1,numFcns);
  for i=1:numFcns
    param{i} = struct(feval(fcn{i},'defaultParam'));
  end
end

% ===========================================================

function flag = isrealmat(mat,m,n)
% ISREALMAT(MAT,M,N) is true if MAT is a MxN real matrix.
% If M or N is NaN, that dimension to be anything.

flag = isa(mat,'double');
if ~flag, return, end
flag = isreal(mat);
if ~flag, return, end
if isnan(m), m = size(mat,1); end
if isnan(n), n = size(mat,2); end
flag = all(size(mat) == [m n]);

% ===========================================================
%% SUBSCRIPTS AND FIELDS
% ===========================================================

function [subscripts,subs,type,moresubs]=nextsubs(subscripts)
% NEXTSUBS get subscript data from a subscript array.

subs = subscripts(1).subs;
type = subscripts(1).type;
subscripts(1) = [];
moresubs = ~isempty(subscripts);

% ===========================================================

function [field,found] = matchstring(field,strings)
% MATCHFIELD replaces FIELD with any field belonging to STRUCTURE
% that is the same when case is ignored.

for i=1:length(strings)
  if strcmpi(field,strings{i})
    field = strings{i};
    found = true;
    return;
  end
end
found = false;

% ===========================================================

function [sub1,err] = subs1(subs,dim)
% SUBS1(SUBS,DIM) converts N-D subscripts SUBS to 1-D equivalents
% given the dimensions DIM of the index space.

err = '';
sub1 = 0;

m = 1:prod(dim);
m = reshape(m,dim);
try
  sub1 = m(subs{:});
catch me
  err = me.message;
  return;
end
sub1 = sub1(:)';

% ===========================================================

function [sub1,sub2,err] = subs2(subs,dim)
% [SUB1,SUB2]=SUBS2(SUBS,DIM) converts N-D subscripts SUBS to
% 1-D equivalents given the dimensions DIM of the index space.

err = '';
sub1 = 0;
sub2 = 0;

m1 = (1:dim(1))';
m1 = m1(:,ones(1,dim(2)),:);
try
  sub1 = m1(subs{:});
catch me
  err = me.message;
  return;
end
m2 = 1:dim(2);
m2 = m2(ones(1,dim(1)),:);
sub2 = m2(subs{:});

sub1 = sub1(:)';
sub2 = sub2(:)';

% ===========================================================

function [o,err]=nsubsasn(o,subscripts,v)
%NSUBSASN General purpose subscript assignment.

% Assume no error
err = '';

% Null case
if isempty(subscripts)
  o = v;
  return
end

type = subscripts(1).type;
subs = subscripts(1).subs;
subscripts(1) = [];

switch type
  
  % Parentheses
  case '()'
    try
      o2=o(subs{:});
    catch me
      err=me.message;
      return
    end
    [v,err] = nsubsasn(o2,subscripts,v);
    if ~isempty(err), return, end
    try
      o(subs{:})=v;
    catch me
      err=me.message;
      return;
    end
  
  % Curly Brackets
  case '{}'
    try
      o2=o{subs{:}};
    catch me
      err=me.message;
      return;
    end
    [v,err] = nsubsasn(o2,subscripts,v);
    if ~isempty(err), return, end
    try
      o{subs{:}}=v;
    catch me
      err=me.message;
      return
    end
  
  % Dot
  case '.'
    
    % Apply field to cell of structures or objects
    if isa(o,'cell')
      if nn_iscellstruct_field(o,subs)
        o2 = cell(size(o));
        for i = 1:numel(o)
          o2{i}.(subs) = v{i}.(subs);
        end
        return;
      end
    end
    
    % Match field name regardless of case
    if isa(o,'struct') || isobject(o)
      found = 0;
      f = fieldnames(o);
      for i=1:length(f)
        if strcmpi(subs,f{i})
          subs = f{i};
        found = 1;
        break;
        end
      end
      if (~found)
        try
          o.(subs)=v;
        catch me
          err=me.message;
          return
        end
        return
      end
    else
      err = 'Attempt to reference field of non-structure array.';
      return
    end
    try
      o2=o.(subs);
    catch me
      err=me.message;
      return;
    end
    [v,err] = nsubsasn(o2,subscripts,v);
    if ~isempty(err), return, end
    try
      o.(subs)=v;
    catch me
      err = me.message;
      return;
    end
end

% ===========================================================
function [net,err] = nsubasgn_cellfield(net,field,subs,v,subscripts)

subscripts1.type = '.';
subscripts1.subs = field;
subscripts2.type = '{}';
subscripts2.subs = {0};
subscripts3.type = '.';
subscripts3.subs = subs;
subscriptsi = [subscripts1 subscripts2 subscripts3];

err = '';
if ~iscell(v)
  err = ['Attempt to assign net.' field '.' subs ' with non-cell array.'];
elseif ~all(size(v) == size(net.(field)))
  err = ['Cell array of values has different dimensions than net.' field '.'];
else
  for i = 1:numel(v)
    vi = v{i};
    ni = net.(field){i};
    if isempty(ni)
      if ~isempty(vi)
        err = 'Attempt to set field of empty cell array element.';
        return
      end
    else
      if ~isempty(subscripts)
        [vi,err] = nsubsasn(net.(field){i}.size,subscripts,vi);
      end
      if ~isempty(err),break; end
      subscriptsi(2).subs = {i};
      net = network_subsasgn(net,subscriptsi,vi);
      %net.(field){i}.(subs) = vi;
    end
  end
end

% ===========================================================

function x = newLayer
x.dimensions = 0; % 1-dimension of size 0
x.distanceFcn = '';
x.distanceParam = struct;
x.distances = [];
x.initFcn = 'initwb';
x.name = 'Layer';
x.netInputFcn = 'netsum';
x.netInputParam = getDefaultParam('netsum');
x.positions = zeros(0,1);
x.range = zeros(0,2);
x.size = 0;
x.topologyFcn = '';
x.transferFcn = 'purelin';
x.transferParam = getDefaultParam('purelin');
x.userdata.note = 'Put your custom layer information here.';
    
function x = newOutput
x.name = 'Output';
x.feedbackInput = [];
x.feedbackDelay = 0;
x.feedbackMode = 'none';
x.processFcns = cell(1,0);
x.processParams = cell(1,0);
x.processSettings = cell(1,0);
x.processedRange = zeros(0,2);
x.processedSize = 0;
x.range = zeros(0,2);
x.size = 0;
x.userdata.note = 'Put your custom output information here.';
% NNET 6.0 Compatibility
x.exampleOutput = [];
    
function x = newWeight
x.delays = 0;
x.initFcn = '';
x.initSettings = [];
x.learn = 1;
x.learnFcn = '';
x.learnParam = struct;
x.size = [0 0];
x.userdata.note = 'Put your custom weight information here.';
x.weightFcn = 'dotprod';
x.weightParam = struct;
    
function x = newBias
x.initFcn = '';
x.learn = true;
x.learnFcn = '';
x.learnParam = struct;
x.size = 0;
x.userdata.note = 'Put your custom layer information here.';
