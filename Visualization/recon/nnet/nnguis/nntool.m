function result = nntool(event)
%NNTOOL Neural Network Toolbox graphical user interface.
%
%  Syntax
%
%    nntool
%
%  Description
%
%    NNTOOL opens the Network/Data Manager window which allows
%    you to import, create, use, and export neural networks
%    and data.

% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.10.7 $  $Date: 2011/05/09 01:03:05 $

if nargout > 0, result = []; end

% Constants
MAX_ELEMENTS_IN_MATRIX_STRINGS = 1000;

% NNTool Data
persistent STATE;

% Setup State
if (isempty(STATE))
  mlock
  emptyDef.names = {};
  emptyDef.values = {};
  STATE.network = emptyDef;
  STATE.input = emptyDef;
  STATE.target = emptyDef;
  STATE.inputstate = emptyDef;
  STATE.layerstate = emptyDef;
  STATE.output = emptyDef;
  STATE.error = emptyDef;
  STATE.tool = nnjava.tools('nntool');
elseif ~STATE.tool.isVisible
  % Clear State if NNTool has been closed
  emptyDef.names = {};
  emptyDef.values = {};
  STATE.network = emptyDef;
  STATE.input = emptyDef;
  STATE.target = emptyDef;
  STATE.inputstate = emptyDef;
  STATE.layerstate = emptyDef;
  STATE.output = emptyDef;
  STATE.error = emptyDef;
end

% Can't proceed unless we have desktop java support
if ~usejava('swing')
  nnerr.throw('missingJavaSwing',...
    'Cannot use nntool unless you have Java and Swing available.');
end

% Launch NNTool
if nargin == 0
  STATE.tool.launch;
  if nargout > 0, result = STATE.tool; end
  return
end

% State
if ischar(event), result = STATE; return; end
  
% Event Type
eventType = elementAt(event,0);
if ~ischar(eventType)
  eventType = char(eventType);
end
switch eventType
  
  case 'doc'
    target = char(elementAt(event,1));
    doc(target)
    return
  case 'doc_nnet'
    doc('nnet');
    return
  case 'doc_demos'
    doc('nndemos');
    return
  case 'doc_datasets'
    doc('nndatasets');
    return
  case 'doc_textbook'
    doc('nntextbook');
    return
  case 'doc_textdemos'
    doc('nntextdemos')
    return
    
  case 'nop'
    % No Operation
    
  case 'clearState'
    STATE = [];
    
  case 'checkvalue'
    try
      name = char(elementAt(event,1));
      valueString = char(elementAt(event,2));
      returnVector = elementAt(event,3);

      err = 0;
      if ischar(valueString)
        valueString = nnjava.tools('string',valueString);
      end
      if (valueString.equals('<NO_INPUT>'))
        err = 1;
      elseif (valueString.equals('<NO_TARGET>'))
        err = 1;
      elseif (valueString.startsWith('INPUT:'))
        err = 0;
      elseif (valueString.startsWith('TARGET:'))
        err = 0;
      else
        try
          value = eval(valueString);
        catch
          err=1;
        end
        if (err)
          err = ~exist(valueString);
        end
      end
      if (err)
        mstring = [name ' is not a legal value.'];
        jstring = nnjava.tools('string',mstring);
        addElement(returnVector,jstring);
      end
    catch me
      error_message = 'Error in nntool:checkvalue';
      last_error = me;
      save error_file error_message last_error
    end
    
case 'getweightnames'
    networkName = char(elementAt(event,1));
    net = getValue(STATE,networkName);
    weightNames = elementAt(event,2);
    numInputs = net.numInputs;
    numLayers = net.numLayers;
    for j=1:numInputs
        for i=1:numLayers
            if net.inputConnect(i,j)
                weightName = sprintf('iw{%g,%g} - Weight to layer %g from input %g',i,j,i,j);
                jstring = nnjava.tools('string',weightName);
                addElement(weightNames,jstring);
            end
        end
    end
    for j=1:numLayers
        for i=1:numLayers
            if net.layerConnect(i,j)
                weightName = sprintf('lw{%g,%g} - Weight to layer %g from layer %g',i,j);
                jstring = nnjava.tools('string',weightName);
                addElement(weightNames,jstring);
            end
        end
    end
    for i=1:numLayers
        if net.biasConnect(i)
            weightName = sprintf('b{%g} - Bias to layer %g',i,i);
            jstring = nnjava.tools('string',weightName);
            addElement(weightNames,jstring);
        end
    end
    
case 'getweightvalue'
    networkName = char(elementAt(event,1));
    net = getValue(STATE,networkName);
    weightName = char(elementAt(event,2));
    weightName = weightName(1:strfind(weightName,'}'));
    returnVector = elementAt(event,3);
    weightValue = eval(['net.' weightName]);
    if numel(weightValue) <= MAX_ELEMENTS_IN_MATRIX_STRINGS
      mstring = nnstring.mat2string(weightValue);
    else
      mstring = '?';
    end
    jstring = nnjava.tools('string',mstring);
    addElement(returnVector,jstring);
    
case 'checkweightvalue'
    networkName = char(elementAt(event,1));
    net = getValue(STATE,networkName);
    weightName = char(elementAt(event,2));
    weightName = weightName(1:strfind(weightName,'}'));
    weightValue = char(elementAt(event,3));
    returnVector = elementAt(event,4);
    
    eval(['oldweight=net.' weightName ';']);
    [S,R] = size(oldweight);
    
    err = 0;
    range = [];
    eval(['weight=' weightValue ';'],'err=1;');
    if (err)
        addElement(returnVector,nnjava.tools('string','Value is not a legal matrix.'));
    elseif ~isa(weight,'double')
        addElement(returnVector,nnjava.tools('string','Value is not a matrix.'));
    elseif size(weight,1) ~= S
        addElement(returnVector,nnjava.tools('string',['Value does not have ' num2str(S) ' rows.']));
    elseif size(weight,2) ~= R
        addElement(returnVector,nnjava.tools('string',['Value does not have ' num2str(R) ' columns.']));
    end
    
case 'setweightvalue'
    networkName = char(elementAt(event,1));
    net = getValue(STATE,networkName);
    weightName = char(elementAt(event,2));
    weightName = weightName(1:strfind(weightName,'}'));
    weightValue = char(elementAt(event,3));
    eval(['net.' weightName '=' weightValue ';']);
    STATE = setValue(STATE,networkName,net);
    
case 'getinputranges'
    networkName = char(elementAt(event,1));
    net = getValue(STATE,networkName);
    returnVector = elementAt(event,2);
    rangesValue = net.inputs{1}.range;
    if (numel(rangesValue) <= MAX_ELEMENTS_IN_MATRIX_STRINGS)
      mstring = nnstring.mat2string(rangesValue);
    else
      mstring = '?';
    end
    addElement(returnVector,nnjava.tools('string',mstring));
    
case 'checkinputranges'
    
    networkName = char(elementAt(event,1));
    net = getValue(STATE,networkName);
    rangesValue = char(elementAt(event,2));
    returnVector = elementAt(event,3);
    
    R = net.inputs{1}.size;
    
    err = 0;
    range = [];
    eval(['range=' rangesValue ';'],'err=1;');
    if (err)
        jstring = nnjava.tools('string','Input Ranges is not a legal matrix.');
        addElement(returnVector,jstring);
    elseif ~isa(range,'double')
        jstring = nnjava.tools('string','Input Ranges is not a matrix.');
        addElement(returnVector,jstring);
    elseif size(range,2) ~= 2
        jstring = nnjava.tools('string','Input Ranges does not have 2 columns.');
        addElement(returnVector,jstring);
    elseif size(range,1) ~= R
        jstring = nnjava.tools('string',['Input Ranges does not have ' num2str(R) ' rows.']);
        addElement(returnVector,jstring);
    end
    
case 'setinputranges'
    networkName = char(elementAt(event,1));
    net = getValue(STATE,networkName);
    rangesValue = char(elementAt(event,2));
    eval(['net.inputs{1}.range=' rangesValue ';']);
    STATE = setValue(STATE,networkName,net);
    
case 'getnetworkinfo'
    name = char(elementAt(event,1));
    returnVector = elementAt(event,2);
    net = getValue(STATE,name);
    jtrue = nnjava.tools('string','true');
    jfalse = nnjava.tools('string','false');
    conditionalAppend(returnVector,net.numInputs ~=0,jtrue,jfalse);
    conditionalAppend(returnVector,net.numOutputs ~=0,jtrue,jfalse);
    conditionalAppend(returnVector,net.numInputDelays ~=0,jtrue,jfalse);
    conditionalAppend(returnVector,net.numLayerDelays ~=0,jtrue,jfalse);
    conditionalAppend(returnVector,~strcmp(net.trainFcn,''),jtrue,jfalse);
    conditionalAppend(returnVector,~strcmp(net.adaptFcn,''),jtrue,jfalse);
    
case 'getdata'
    name = char(elementAt(event,1));
    value = getValue(STATE,name);
    if all(size(value) == [1 1])
        mstring = nnstring.mat2string(value{1,1});
    else
        mstring = nnstring.cell2string(value);
    end
    returnVector = elementAt(event,2);
    addElement(returnVector,nnjava.tools('string',mstring));
        
case 'getdatarange'
    name = char(elementAt(event,1));
    returnVector = elementAt(event,2);
    value = getValue(STATE,name);
    range = minmax(value);
    if iscell(range) && all(size(range)==[1 1])
      mstring = mat2str(range{1,1});
    elseif iscell(range)
      mstring = nnstring.cell2string(range);
    else
      mstring = mat2str(range);
    end
    addElement(returnVector,nnjava.tools('string',mstring));
    
case 'checkdata'
    mstring = char(elementAt(event,1));
    err = [];
    value = [];
    eval(['value=' mstring ';'],'err=''Data is not a legal value.'';');
    if isempty(err)
      err = nntype.data('check',value,'Data');
    end
    if ~isempty(err)
      returnVector = elementAt(event,2);
      addElement(returnVector,nnjava.tools('string',err));
    end
    
case 'setdata'
    name = char(elementAt(event,1));
    mstring = char(elementAt(event,2));
    value = eval([mstring ';']);
    if isa(value,'double')
        value = {value};
    end
    STATE = setValue(STATE,name,value);
    
case 'newnet'
  
  params = [];
  networkName = [];
  func = [];
  i = -1;
  try
  % lower to workaround the case-sensitivity of UNIX
    returnVector = elementAt(event,4);
    networkName = char(elementAt(event,1));
    func = lower(char(elementAt(event,2)));
    
    try
      params = j2mparam(STATE,elementAt(event,3));
    catch me
      addElement(returnVector,nnjava.tools('string',me.message));
      return
    end

    for i=1:length(params)
      param = params{i};
      if ischar(param)
        params{i}=lower(param);
      end
    end

    try
      net=feval(func,params{:});
    catch me
      addElement(returnVector,nnjava.tools('string',me.message));
      return
    end
    STATE.network = addDef(STATE.network,networkName,net);
    
  catch me
    addElement(returnVector,nnjava.tools('string','Unknown error prevented creation of new network.'));
    error_message = 'Error in nntool:newnet';
    last_error = me;
    save error_file error_message last_error networkName func params i
  end
  
case 'newinput'
    name = char(elementAt(event,1));
    value = eval(char(elementAt(event,2)));
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.input = addDef(STATE.input,name,value);
    
case 'newtarget'
    name = char(elementAt(event,1));
    value = eval(char(elementAt(event,2)));
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.target = addDef(STATE.target,name,value);
    
case 'newinputstate'
    name = char(elementAt(event,1));
    value = eval(char(elementAt(event,2)));
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.inputstate = addDef(STATE.inputstate,name,value);
    
case 'newlayerstate'
    name = char(elementAt(event,1));
    value = eval(char(elementAt(event,2)));
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.layerstate = addDef(STATE.layerstate,name,value);
    
case 'newoutput'
    name = char(elementAt(event,1));
    value = eval(char(elementAt(event,2)));
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.output = addDef(STATE.output,name,value);
    
case 'newerror'
    name = char(elementAt(event,1));
    value = eval(char(elementAt(event,2)));
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.error = addDef(STATE.error,name,value);
    
case 'importnet'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    value = evalin('base',variable);
    STATE = deleteAllDefsByName(STATE,name);
    STATE.network = addDef(STATE.network,name,value);
    
case 'importinput'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    
    STATE = deleteAllDefsByName(STATE,name);
    STATE.input = addDef(STATE.input,name,value);
    
case 'importtarget'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.target = addDef(STATE.target,name,value);
    
case 'importinputstate'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.inputstate = addDef(STATE.inputstate,name,value);
    
case 'importlayerstate'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.layerstate = addDef(STATE.layerstate,name,value);
    
case 'importoutput'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.output = addDef(STATE.output,name,value);
    
case 'importerror'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.error = addDef(STATE.error,name,value);
    
case 'loadnet'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    path = char(elementAt(event,3));
    s = load(path,variable);
    value = s.(variable);
    STATE = deleteAllDefsByName(STATE,name);
    STATE.network = addDef(STATE.network,name,value);
    
case 'loadinput'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    path = char(elementAt(event,3));
    s = load(path,variable);
    value = s.(variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.input = addDef(STATE.input,name,value);
    
case 'loadtarget'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    path = char(elementAt(event,3));
    s = load(path,variable);
    value = s.(variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.target = addDef(STATE.target,name,value);
    
case 'loadinputstate'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    path = char(elementAt(event,3));
    s = load(path,variable);
    value = s.(variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.inputstate = addDef(STATE.inputstate,name,value);
    
case 'loadlayerstate'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    path = char(elementAt(event,3));
    s = load(path,variable);
    value = s.(variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.layerstate = addDef(STATE.layerstate,name,value);
    
case 'loadoutput'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    path = char(elementAt(event,3));
    s = load(path,variable);
    value = s.(variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.output = addDef(STATE.output,name,value);
    
case 'loaderror'
    name = char(elementAt(event,1));
    variable = char(elementAt(event,2));
    path = char(elementAt(event,3));
    s = load(path,variable);
    value = s.(variable);
    if isa(value,'double')
        value = {value};
    end
    STATE = deleteAllDefsByName(STATE,name);
    STATE.error = addDef(STATE.error,name,value);
    
case 'delete';
    name = char(elementAt(event,1));
    STATE = deleteAllDefsByName(STATE,name);
    
case 'initialize'
    name = char(elementAt(event,1));
    i = nnstring.first_match(name,STATE.network.names);
    STATE.network.values{i} = init(STATE.network.values{i});
    
case 'revert'
    name = char(elementAt(event,1));
    i = nnstring.first_match(name,STATE.network.names);
    STATE.network.values{i} = revert(STATE.network.values{i});
    
case 'simulate'
    networkName = char(elementAt(event,1));
    inputsName = char(elementAt(event,2));
    initInputStatesName = char(elementAt(event,3));
    initLayerStatesName = char(elementAt(event,4));
    targetsName = char(elementAt(event,5));
    
    % Sim results
    outputsName = char(elementAt(event,6));
    finalInputStatesName = char(elementAt(event,7));
    finalLayerStatesName = char(elementAt(event,8));
    errorsName = char(elementAt(event,9));
    
    % Error return vector
    returnVector = elementAt(event,10);
    net = getValueByName(STATE.network,networkName);
    if (strcmp(inputsName,'(zeros)'))
        P = inputZeros(net);
    else
        P = getValueByName(STATE.input,inputsName);
    end
    if (strcmp(initInputStatesName,'(zeros)'))
        Pi = {};
    else
        Pi = getValueByName(STATE.inputstate,initInputStatesName);
    end
    if (strcmp(initLayerStatesName,'(zeros)'))
        Ai = {};
    else
        Ai = getValueByName(STATE.layerstate,initLayerStatesName);
    end
    if (strcmp(targetsName,'(zeros)'))
        T = {};
    else
        T = getValueByName(STATE.target,targetsName);
    end
    err = 0;
    try
      [Y,Pf,Af,E] = sim(net,P,Pi,Ai,T);
    catch me
      err = 1;
    end
    if (err)
        jstring = nnjava.tools('string',me.message);
        addElement(returnVector,jstring);
    else
        if ~isempty(outputsName)
            STATE = deleteAllDefsByName(STATE,outputsName);
            STATE.output = addDef(STATE.output,outputsName,Y);
        end
        if ~isempty(finalInputStatesName)
            STATE = deleteAllDefsByName(STATE,finalInputStatesName);
            STATE.inputstate = addDef(STATE.inputstate,finalInputStatesName,Pf);
        end
        if ~isempty(finalLayerStatesName)
            STATE = deleteAllDefsByName(STATE,finalLayerStatesName);
            STATE.layerstate = addDef(STATE.layerstate,finalLayerStatesName,Af);
        end
        if ~isempty(errorsName)
            STATE = deleteAllDefsByName(STATE,errorsName);
            STATE.error = addDef(STATE.error,errorsName,E);
        end
        
    end
    
    % TRAIN
case 'train'
    networkName = char(elementAt(event,1));
    inputsName = char(elementAt(event,2));
    initInputStatesName = char(elementAt(event,3));
    initLayerStatesName = char(elementAt(event,4));
    targetsName = char(elementAt(event,5));
    
    % Training results
    outputsName = char(elementAt(event,6));
    finalInputStatesName = char(elementAt(event,7));
    finalLayerStatesName = char(elementAt(event,8));
    errorsName = char(elementAt(event,9));
    
    % Error return vector
    returnVector = elementAt(event,10);
    
    % Get training data
    net = getValueByName(STATE.network,networkName);
    if (strcmp(inputsName,'(zeros)'))
        P = inputZeros(net);
    else
        P = getValueByName(STATE.input,inputsName);
    end
    if (strcmp(initInputStatesName,'(zeros)'))
        Pi = {};
    else
        Pi = getValueByName(STATE.inputstate,initInputStatesName);
    end
    if (strcmp(initLayerStatesName,'(zeros)'))
        Ai = {};
    else
        Ai = getValueByName(STATE.layerstate,initLayerStatesName);
    end
    if (strcmp(targetsName,'(zeros)'))
        T = {};
    else
        T = getValueByName(STATE.target,targetsName);
    end
    
    err = 0;
    try
      [net,tr,Y,E,Pf,Af] = train(net,P,T,Pi,Ai);
    catch me
      err=1;
    end
    if (err)
       jstring = nnjava.tools('string',me.message);
       addElement(returnVector,jstring);
    else
        STATE.network.values{nnstring.first_match(networkName,STATE.network.names)} = net;
        if (length(outputsName) > 0)
            STATE = deleteAllDefsByName(STATE,outputsName);
            STATE.output = addDef(STATE.output,outputsName,Y);
        end
        if (length(finalInputStatesName) > 0)
            STATE = deleteAllDefsByName(STATE,finalInputStatesName);
            STATE.inputstate = addDef(STATE.inputstate,finalInputStatesName,Pf);
        end
        if (length(finalLayerStatesName) > 0)
            STATE = deleteAllDefsByName(STATE,finalLayerStatesName);
            STATE.layerstate = addDef(STATE.layerstate,finalLayerStatesName,Af);
        end
        if (length(errorsName) > 0)
            STATE = deleteAllDefsByName(STATE,errorsName);
            STATE.error = addDef(STATE.error,errorsName,E);
        end      
    end
    
case 'adapt'
    networkName = char(elementAt(event,1));
    inputsName = char(elementAt(event,2));
    initInputStatesName = char(elementAt(event,3));
    initLayerStatesName = char(elementAt(event,4));
    targetsName = char(elementAt(event,5));
    outputsName = char(elementAt(event,6));
    finalInputStatesName = char(elementAt(event,7));
    finalLayerStatesName = char(elementAt(event,8));
    errorsName = char(elementAt(event,9));
    returnVector = elementAt(event,10);
    net = getValueByName(STATE.network,networkName);
    if (strcmp(inputsName,'(zeros)'))
        P = inputZeros(net);
    else
        P = getValueByName(STATE.input,inputsName);
    end
    if (strcmp(initInputStatesName,'(zeros)'))
        Pi = {};
    else
        Pi = getValueByName(STATE.inputstate,initInputStatesName);
    end
    if (strcmp(initLayerStatesName,'(zeros)'))
        Ai = {};
    else
        Ai = getValueByName(STATE.layerstate,initLayerStatesName);
    end
    if (strcmp(targetsName,'(zeros)'))
        T = {};
    else
        T = getValueByName(STATE.target,targetsName);
    end
    err = 0;
    try
      [net,Y,E,Pf,Af] = adapt(net,P,T,Pi,Ai);
    catch me
      err=1;
    end
    if (err)
        jstring = nnjava.tools('string',me.message);
        addElement(returnVector,jstring);
    else
        STATE.network.values{nnstring.first_match(networkName,STATE.network.names)} = net;
        if (length(outputsName) > 0)
            STATE = deleteAllDefsByName(STATE,outputsName);
            STATE.output = addDef(STATE.output,outputsName,Y);
        end
        if (length(finalInputStatesName) > 0)
            STATE = deleteAllDefsByName(STATE,finalInputStatesName);
            STATE.inputstate = addDef(STATE.inputstate,finalInputStatesName,Pf);
        end
        if (length(finalLayerStatesName) > 0)
            STATE = deleteAllDefsByName(STATE,finalLayerStatesName);
            STATE.layerstate = addDef(STATE.layerstate,finalLayerStatesName,Af);
        end
        if (length(errorsName) > 0)
            STATE = deleteAllDefsByName(STATE,errorsName);
            STATE.error = addDef(STATE.error,errorsName,E);
        end
    end
    
case 'gettrainparams'
    networkName = char(elementAt(event,1));
    names = elementAt(event,2);
    values = elementAt(event,3);
    net = getValueByName(STATE.network,networkName);
    trainParam = net.trainParam;
    if (isempty(trainParam))
        fields = {};
    else
        fields = fieldnames(trainParam);
    end
    num = size(fields,1);
    for i=1:num
        field = fields{i};
        name = nnjava.tools('string',field);
        value = nnjava.tools('string',mat2str(trainParam.(field)));
        addElement(names,name);
        addElement(values,value)
    end
    
case 'settrainparams'
    networkName = char(elementAt(event,1));
    values = elementAt(event,2);
    net = getValueByName(STATE.network,networkName);
    trainParam = net.trainParam;
    if (isempty(trainParam))
        fields = {};
    else
        fields = fieldnames(trainParam);
    end
    num = size(fields,1);
    for i=1:num
        field = fields{i};
        value = eval(char(elementAt(values,i-1)));
        trainParam.(field) = value;
    end
    net.trainParam = trainParam;
    STATE.network.values{nnstring.first_match(networkName,STATE.network.names)} = net;
    
case 'getadaptparams'
    networkName = char(elementAt(event,1));
    names = elementAt(event,2);
    values = elementAt(event,3);
    net = getValueByName(STATE.network,networkName);
    adaptParam = net.adaptParam;
    if (isempty(adaptParam))
        fields = {};
    else
        fields = fieldnames(adaptParam);
    end
    num = size(fields,1);
    for i=1:num
        field = fields{i};
        name = nnjava.tools('string',field);
        value = nnjava.tools('string',mat2str(adaptParam.(field)));
        addElement(names,name);
        addElement(values,value)
    end
    
case 'setadaptparams'
    networkName = char(elementAt(event,1));
    values = elementAt(event,2);
    net = getValueByName(STATE.network,networkName);
    adaptParam = net.adaptParam;
    if (isempty(adaptParam))
        fields = {};
    else
        fields = fieldnames(adaptParam);
    end
    num = size(fields,1);
    for i=1:num
        value = eval(char(elementAt(values,i-1)));
        field = fields{i};
        adaptParams.(field) = value;
    end
    net.adaptParam = adaptParam;
    STATE.network.values{nnstring.first_match(networkName,STATE.network.names)} = net;
    
case 'getwsvars'
    names = elementAt(event,1);
    variables = evalin('base','who');
    for i=1:length(variables)
        variable = variables{i};
        addElement(names,nnjava.tools('string',variable));
    end

case 'getwsvartype'
    name = char(elementAt(event,1));
    returnVector = elementAt(event,2);
    value = evalin('base',name,'''UNKNOWN''');
    if isa(value,'network')
      code = 'NETWORK';
    elseif nnisdata(value)
      code = 'DATA';
    else
      code = 'UNKNOWN';
    end
    addElement(returnVector,nnjava.tools('string',code));
    
case 'getfilevars'
    thepath = char(elementAt(event,1));
    names = elementAt(event,2);
    variables = evalin('base',['who(''-file'',''' thepath ''')']);
    for i=1:length(variables)
        variable = variables{i};
        addElement(names,nnjava.tools('string',variable));
    end
    
case 'getfilevartype'
    thepath = char(elementAt(event,1));
    name = char(elementAt(event,2));
    returnVector = elementAt(event,3);
    valueStruct = load(thepath,name);
    value = valueStruct.(name);
    if isa(value,'network')
      code = 'NETWORK';
    elseif nnisdata(value)
      code = 'DATA';
    else
      code = class(value); %'UNKNOWN';
    end
    addElement(returnVector,nnjava.tools('string',code));
    
case 'export'
    variables = elementAt(event,1);
    count = double(size(variables));
    for i=1:count
        variable = char(elementAt(variables,i-1));
        value = getValue(STATE,variable);
        if (all(size(value) == [1  1]))
            if isa(value,'cell')
                value = value{1,1};
            end
        end
    assignin('base',variable,value);
    end
    
case 'save'
    path = char(elementAt(event,1));
    variables = elementAt(event,2);
    count = double(size(variables));
    names = {};
    for i=1:count
        variable = char(elementAt(variables,i-1));
        value = getValue(STATE,variable);
        eval([variable ' = value;']);
        names = [names {variable}];
    end
    save(path,names{:});
    
case 'getdiagram'
    networkName = char(elementAt(event,1));
    descVector = elementAt(event,2);
    net = getValueByName(STATE.network,networkName);
    descVector.add(nnjava.tools('diagram',net));
    
case 'newdiagram'
    try
      errorHolder = elementAt(event,1);
      func = lower(char(elementAt(event,2)));
      params = j2mparam(STATE,elementAt(event,3));
      net = feval(func,params{:});
      errorHolder.removeAllElements();
      view(net);
    catch
      errorVector.add('error');
    end
end

%==========================================
function getNetworkDescription(net,descVector)
% Puts a description of NET into Java vector DESCVECTOR

if (net.numInputs == 1)
    switch (net.numLayers)
    case 1
        if (net.inputConnect == 1) && (net.layerConnect == 0)
            % Single layer network
            % descVector = ['ff1' inputSize
            %   layerSize netInputFcn transferFcn]
            addElement(descVector,nnjava.tools('string','ff1'));
            addElement(descVector,nnjava.tools('string',num2str(net.inputs{1}.size)));
            addElement(descVector,nnjava.tools('string',num2str(net.layers{1}.size)));
            n1 = net.layers{1}.netInputFcn;
            addElement(descVector,nnjava.tools('string',n1));
            f1 = net.layers{1}.transferFcn;
            addElement(descVector,nnjava.tools('string',f1));
        else
          addElement(descVector,nnjava.tools('string','unknown'));
        end
    case 2
        % Two layer feed-forward network
        % descVector = ['ff2' inputSize
        %   layerSize1 netInputFcn1 transferFcn1
        %   layerSize2 netInputFcn2 transferFcn2]
        if all(net.inputConnect==[1;0]) && all(all(net.layerConnect==[0 0;1 0]))
            addElement(descVector,nnjava.tools('string','ff2'));
            addElement(descVector,nnjava.tools('string',num2str(net.inputs{1}.size)));
            addElement(descVector,nnjava.tools('string',num2str(net.layers{1}.size)));
            n1 = net.layers{1}.netInputFcn;
            addElement(descVector,nnjava.tools('string',n1));
            f1 = net.layers{1}.transferFcn;
            addElement(descVector,nnjava.tools('string',f1));
            addElement(descVector,nnjava.tools('string',num2str(net.layers{2}.size)));
            n2 = net.layers{2}.netInputFcn;
            addElement(descVector,nnjava.tools('string',n2));
            f2 = net.layers{2}.transferFcn;
            addElement(descVector,nnjava.tools('string',f2));
        else
          addElement(descVector,nnjava.tools('string','unknown'));
        end
    case 3
        if all(net.inputConnect==[1;0;0]) && all(all(net.layerConnect==[0 0 0;1 0 0;0 1 0]))
            % Three layer feed-forward network
            % descVector = ['ff3' inputSize
            %   layerSize1 netInputFcn1 transferFcn1
            %   layerSize2 netInputFcn2 transferFcn2
            %   layerSize3 netInputFcn3 transferFcn3]
            addElement(descVector,nnjava.tools('string','ff3'));
            addElement(descVector,nnjava.tools('string',num2str(net.inputs{1}.size)));
            addElement(descVector,nnjava.tools('string',num2str(net.layers{1}.size)));
            n1 = net.layers{1}.netInputFcn;
            addElement(descVector,nnjava.tools('string',n1));
            f1 = net.layers{1}.transferFcn;
            addElement(descVector,nnjava.tools('string',f1));
            addElement(descVector,nnjava.tools('string',num2str(net.layers{2}.size)));
            n2 = net.layers{2}.netInputFcn;
            addElement(descVector,nnjava.tools('string',n2));
            f2 = net.layers{2}.transferFcn;
            addElement(descVector,nnjava.tools('string',f2));
            addElement(descVector,nnjava.tools('string',num2str(net.layers{3}.size)));
            n3 = net.layers{3}.netInputFcn;
            addElement(descVector,nnjava.tools('string',n3));
            f3 = net.layers{3}.transferFcn;
            addElement(descVector,nnjava.tools('string',f3));
        else
          addElement(descVector,nnjava.tools('string','unknown'));
        end
      otherwise
        addElement(descVector,nnjava.tools('string','unknown'));
    end
  else
  addElement(descVector,nnjava.tools('string','unknown'));
end

%==========================================
function value = getValue(data,name)

f=fields(data);
for i=1:length(f)
  defs = data.(f{i});
  index = nnstring.first_match(name,defs.names);
  if (index)
      value = defs.values{index};
      return;
  end
end
value = [];
set(gcf,'name','getValue-fail');

%==========================================
function P = inputZeros(net)

P = cell(net.numInputs,1);
for i=1:net.numInputs
    P{i,1} = zeros(net.inputs{i}.size);
end

%==========================================
function data = setValue(data,name,value)

f = {'network','input','target','inputstate','layerstate','output','error'};
for i=1:length(f);
  defs = data.(f{i});
  index = nnstring.first_match(name,defs.names);
  if (index)
       defs.values{index} = value;
       data.(f{i}) = defs;
  end
end

%==========================================
function value = getValueByName(defs,name)

value = defs.values{nnstring.first_match(name,defs.names)};

%==========================================
function defs = addDef(defs,name,value)

defs.names = [defs.names {name}];
defs.values = [defs.values {value}];

%==========================================
function data = deleteAllDefsByName(data,name)

data.network = deleteDefByName(data.network,name);
data.input = deleteDefByName(data.input,name);
data.target = deleteDefByName(data.target,name);
data.inputstate = deleteDefByName(data.inputstate,name);
data.layerstate = deleteDefByName(data.layerstate,name);
data.output = deleteDefByName(data.output,name);
data.error = deleteDefByName(data.error,name);

%==========================================
function defs = deleteDefByName(defs,name)

i = nnstring.first_match(name,defs.names);
if ~isempty(i)
  defs.names(i) = [];
  defs.values(i) = [];
end

%==========================================
function mparam = j2mparam(STATE,jparam)

FUNCTION_NAME = 0;
INPUT = 2;
TARGET = 3;
if nnjava.tools('isa',jparam,'com_mathworks_toolbox_nnet_nntool_property_NNValue')
    string = char(getString(jparam));
    type = getType(jparam);
    if (type == FUNCTION_NAME)
      mparam = lower(string);
    elseif (type == INPUT)
      if strcmp(string,'<NO_INPUT>'), error(message('nnet:GUI:NoInputSelected')); end
      name = string((length('INPUT:')+1):end);
      mparam = getValue(STATE,name);
    elseif (type == TARGET)
      if strcmp(string,'<NO_TARGET>'), error(message('nnet:GUI:NoTargetSelected')); end
      name = string((length('TARGET:')+1):end);
      mparam = getValue(STATE,name);
    else
      mparam = eval(string);
    end
elseif nnjava.tools('isa',jparam,'java_util_Vector')
    num = double(size(jparam));
    mparam = cell(1,num);
    for i=1:num
        mparam{i} = j2mparam(STATE,elementAt(jparam,i-1));
    end
else
    nnerr.throw('gui',['J2MPARAM can not convert ' class(jparam) ' objects\n']);
end
%==========================================
function conditionalAppend(vector,condition,jtrue,jfalse)

if (condition)
  addElement(vector,jtrue);
else
  addElement(vector,jfalse);
end

%==========================================
function flag = nnisdata(x)

flag = nntype.data('isa',x);
