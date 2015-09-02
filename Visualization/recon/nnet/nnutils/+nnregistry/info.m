function out1 = info(in1,in2)
%NNREGISTRY Neural network modular function registry
%
% NNREGISTRY, with no arguments, returns a structure of information about
% the modular functions in the toolbox, and custom functions which have
% been registered.
%
% NNREGISTRY('add','FCN') adds custom function FCN to the registry, after
% testing it for conformance to modular function conventions.
%
% NNREGISTRY('remove','FCN') removes a custom function FCN.
%
% NNREGISTRY('test') tests all the functions in the registry.
%
% NNREGISTRY('test','type') tests all functions of the given type.
%
% See also NNFCNTYPES.

% Copyright 2010-2011 The MathWorks, Inc.

persistent REGISTRY;
if isempty(REGISTRY)
  REGISTRY = create_registry;
end
if nargin == 0
  out1 = REGISTRY;
elseif (nargin >= 1) && ischar(in1)
  switch(in1)
    case 'exist'
      out1 = exist_function(reg,in2);
    case 'add'
    case 'remove'
    case 'test'  
      if nargin < 2
        err = test_all_functions(REGISTRY);
      else
        err = test_type_functions(REGISTRY,in2);
      end
      if nargout > 0
        out1 = err;
      elseif ~isempty(err)
        nnerr.throw('Type',err);
      end
  end
end

%%
function reg = create_registry

functionTypes = nnregistry.fcn_types;

reg.numModularFcns = 0;
reg.numToolboxFcns = 0;
reg.numCustomFcns = 0;
reg.numTypes = length(functionTypes);
reg.types = functionTypes;
reg.toolboxFcns = {};
for i=1:reg.numTypes
  type = reg.types{i};
  info = feval(type,'info');
  typefield = type(8:end);
  reg.(typefield).mfunction = info.mfunction;
  reg.(typefield).name = info.name;
  reg.(typefield).supportedVersions = info.supportedVersions;
  reg.(typefield).toolboxFolder = info.toolboxFolder;
  reg.(typefield).allFcns = {};
  reg.(typefield).toolboxFcns = get_functions(info.toolboxFolder);
  reg.(typefield).customFcns = {};
  reg.(typefield).allFcns = reg.(typefield).toolboxFcns;
  
  
  reg.numToolboxFcns = reg.numToolboxFcns + length(reg.(typefield).toolboxFcns);
  reg.toolboxFcns = [reg.toolboxFcns reg.(typefield).toolboxFcns];
  disp([typefield ':  ' num2str(length(reg.(typefield).allFcns))]);
end
reg.numModularFcns = reg.numToolboxFcns;

%%
function reg = add_function(reg,fcn)


%%
function flag = exist_function(reg,fcn)

for i=1:reg.numTypes
  type = reg.types{i};
  fcns = reg.(type).allFcns;
  if ~isempty(nnstring.first_match(fcn,fcns))
    flag = true;
    return
  end
end
flag = false;

%%
function err = test_all_functions(reg)

for i=1:reg.numTypes
  type = reg.types{i};
  err = test_type_functions(reg,type);
end

%%
function err = test_type_functions(reg,type)
if isempty(nnstring.first_match(type,reg.types))
  err = 'No such type.';
  return
end
fcns = reg.(type).allFcns;
for j=1:length(fcns)
  fcn = fcns{j};
  disp(['Testing: ' fcn])
  err = feval(type,'check',fcn);
  if ~isempty(err), return; end
end
err = '';
  
%%
function mfunctions = get_functions(folder)

path = fullfile(nnpath.nnet_toolbox,folder);
files = dir(path);
for i=length(files):-1:1
  if files(i).name(1) == '.'
    files(i) = [];
  elseif any(files(i).name(end+[-1 0]) ~= '.m')
    files(i) = [];
  elseif strcmp(files(i).name,'Contents.m')
    files(i) = [];
  elseif ~isempty(nnstring.first_match(files(i).name,{'newc.m','newcf.m','newff.m','newlin.m'}))
    files(i) = [];
  end
end
mfunctions = cell(1,length(files));
for i=1:length(files)
  mfunctions{i} = files(i).name(1:(end-2));
end
