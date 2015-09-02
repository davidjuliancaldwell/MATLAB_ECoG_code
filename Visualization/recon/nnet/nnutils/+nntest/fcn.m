function out1 = fcn(fcn,testSubtype)
%NNTEST.FCN Test a neural network modular function
%
%  NNTEST.FCN('FCN') generates an error if FCN is not the name of a
%  legal neural network modular function.
%
%  ERR = NNTESTFCN('fcn') returns an error string ERR, instead of generating
%  an error.
%
%  Neural network modular functions can be any of the following types,
%  and can be based on any of the respective template custom functions:
%
%    Adaptive Function - <a href="matlab:help custom_adapt">custom_adapt</a>
%    Derivative Function - <a href="matlab:help custom_deriv">custom_deriv</a>
%    Distance Function - <a href="matlab:help custom_distance">custom_distance</a>
%    Division Function - <a href="matlab:help custom_division">custom_division</a>
%    Initialize Layer Function - <a href="matlab:help custom_init_layer">custom_init_layer</a>
%    Initialize Network Function - <a href="matlab:help custom_init_net">custom_init_net</a>
%    Initialize Weight Function - <a href="matlab:help custom_init_weight">custom_init_weight</a>
%    Learning Function - <a href="matlab:help custom_learning">custom_learning</a>
%    Net Input Function - <a href="matlab:help custom_net_input">custom_net_input</a>
%    Network Function - <a href="matlab:help custom_network">custom_network</a>
%    Performance Function - <a href="matlab:help custom_performance">custom_performance</a>
%    Plot Function - <a href="matlab:help custom_plot">custom_plot</a>
%    Processing Function - <a href="matlab:help custom_processing">custom_processing</a>
%    Search Function - <a href="matlab:help custom_search">custom_search</a>
%    Topology Function - <a href="matlab:help custom_topology">custom_topology</a>
%    Training Function - <a href="matlab:help custom_training">custom_training</a>
%    Transfer Function - <a href="matlab:help custom_transfer">custom_transfer</a>
%    Weight Function -  - <a href="matlab:help custom_weight">custom_weight</a>
%
%  For instance, here is how to test CUSTOM_TRAIN:
%
%    err = nntest.fcn('custom_train')
%  
%  See also NNTESTPARAM.

% Copyright 2010-2012 The MathWorks, Inc.

nnassert.minargs(nargin,1);
if nargin < 2, testSubtype = true; end
err = testfunction(fcn);
if isempty(err) && testSubtype
  info = feval(fcn,'info');
  err = feval(info.type,'check',fcn);
end
err = nnerr.value(err,'FCN');
if (nargout > 0)
  out1 = err;
elseif ~isempty(err)
  nnerr.throw('Type',err);
end

function err = testfunction(fcn)

if isa(fcn,'function_handle'), fcn = func2str(fcn);end
fcn = lower(fcn);
if nnstring.ends(fcn,'.m'), fcn = fcn(1:(end-2)); end
i = find(fcn == filesep,1,'last');
if ~isempty(i), fcn = fcn((i+1):end); end

% Function Name
err = nntype.string('check',fcn);
if ~isempty(err), return; end
fcnpath = which(fcn);
if isempty(fcnpath)
  err = 'VALUE is not the name of a function on the MATLAB path.';
  return
end

% Info Object
try
  info = feval(fcn,'info');
catch me %#ok<NASGU>
  err = 'VALUE does not return an info object.';
  return;
end
if ~isa(info,'nnfcnInfo')
  err = 'VALUE does not return an nnfcnInfo object.';
  return;
end

% Info.mfunction
if ~strcmp(fcn,info.mfunction)
  err = 'VALUE info.name is not the same as the function name.';
  return;
end

% Info.type
typeNum = nnstring.first_match(info.type,nnregistry.fcn_types);
if isempty(typeNum)
  err = 'VALUE info.type is not a recognized function type.';
  return;
end
try
  typeInfo = feval(info.type,'info');
catch me %#ok<NASGU>
  err = 'VALUE info.type does not return an nnfcnInfo object.';
  return;
end

% Info.name
err = nntype.string('check',info.name);
if ~isempty(err), err = nnerr.value(err,'VALUE info.name'); return; end

% Info.typeName
err = nntype.string('check',info.typeName);
if ~isempty(err), err = nnerr.value(err,'VALUE info.typeName'); return; end 
if ~strcmp(typeInfo.name,info.typeName) && ~strcmp(typeInfo.name,'Type') % TODO - regularize
  err = 'VALUE info.typeName does not match the name of its type.';
  return;
end

% Info.title
err = nntype.string('check',info.title);
if ~isempty(err), err = nnerr.value(err,'VALUE info.title'); return; end 
title = [info.name ' ' info.typeName];
if ~strcmp(info.title,title)
  err = 'VALUE info.title does not match info.name and info.typeName.';
  return;
end

% info.description
err = nntype.string('check',info.description);
if ~isempty(err), err = nnerr.value(err,'VALUE info.description'); return; end 
description = nnfcn.get_mhelp_title(fcn);
if ~strcmp(info.description,description)
  err = 'VALUE info.description does not match the first comment line of function.';
  return;
end

% info.version
err = nntype.pos_scalar('check',info.version);
if ~isempty(err), err = nnerr.value(err,'VALUE info.version'); return; end
if isempty(find(info.version == typeInfo.supportedVersions,1))
  err = 'VALUE info.version is not a legal version number.';
  return;
end

% info.source
err = nntype.string('check',info.source);
if ~isempty(err), err = nnerr.value(err,'VALUE info.source'); return; end 
if isempty(nnstring.first_match(info.source,{'nnet','custom'}))
  err = 'VALUE info.source is not ''nnet'' or ''custom''.';
  return;
end

% info.subfunctions
if ~isstruct(info.subfunctions)
  err = 'VALUE info.subfunctions is not a struct.';
  return;
end
fn = fieldnames(info.subfunctions);
for i=1:length(fn)
  fni = fn{i};
  sf = info.subfunctions.(fni);
  if strcmp(fni,'self')
    if ~isa(sf,'function_handle') || (~strcmp(func2str(sf),info.mfunction))
      err = ['VALUE info.subfunctions.self is not a function handle to VALUE.'];
      return;
    end
  elseif strcmp(fni,'mfunction')
    if ~nntype.string('isa',sf) || ~strcmp(sf,info.mfunction)
      err = ['VALUE info.mfunction is not set to ''' info.mfunction '''.'];
      return
    end
  elseif ~isempty(nnstring.first_match(fni,...
      {'isScalar','is_dotprod','is_netsum','is_purelin','exist'}))
    if ~nntype.bool_scalar('check',sf)
      err = nnerr.value(err,['VALUE info.' fni']);
      return
    end
  elseif ~isempty(nnstring.first_match(fni,{'w_deriv','p_deriv'}))
    if ~nntype.pos_int_scalar('check',sf)
      err = nnerr.value(err,['VALUE info.' fni']);
      return
    end
  elseif ~isa(sf,'function_handle')
    err = ['VALUE info.subfunctions.' fni ' is not a function handle.'];
    return;
  elseif ~strcmp(fni,func2str(sf))
    err = ['VALUE info.subfunctions.' fni ' refers to subfunction of different name.'];
    return;
  end
end

% info.parameters
if ~isempty(info.parameters) && ~isa(info.parameters,'nnetParamInfo')
  err = 'VALUE info.parameters is not empty or an array of nnetParamInfo.';
  return;
end

% default.param
if ~isempty(info.defaultParam) && ~isa(info.defaultParam,'nnetParam')
  err = 'VALUE info.defaultParam is not a struct.';
  return;
end
if isempty(nnstring.first_match(info.type,{'nntype.weight_init_fcn'}))
  err = feval(fcn,'check_param',info.defaultParam);
  if ~isempty(err), err = nnerr.value(err,'VALUE info.defaultParam.'); return; end
end

