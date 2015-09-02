function fix_mhelp_links(xfile,mnames,params)
%FIX_MHELP_LINKS Convert bracketed references in comments to doc links.

% Copyright 2010-2011 The MathWorks, Inc.

if nargin < 3
  params = dir(fullfile(nnpath.nnet_root,'toolbox','nnet','nnutils','+nnparam'));
  params = { params.name };
  for i = length(params):-1:1
    if strcmp(params{i},'Contents.m') || (params{i}(1)=='.')
      params(i) = [];
    else
      params{i} = params{i}(1:(end-2));
    end
  end
end

if nargin < 2
  mnames = [...
    nnfile.files(fullfile(nnpath.nnet_root,'toolbox','nnet','nnet'),'all'); ...
    nnfile.files(fullfile(nnpath.nnet_root,'toolbox','nnet','nndemos'),'all');
    nnfile.files(fullfile(nnpath.nnet_root,'toolbox','nnet','nnguis'))];
  private = [filesep 'private' filesep];
  for i=length(mnames):-1:1
    if strfind(mnames{i},private)
      mnames(i) = [];
    end
  end
  mnames = nnpath.file2fcn(mnames);
  
  for i=1:length(mnames)
    if nnstring.starts(mnames{i},'network/')
      mnames{i} = mnames{i}(9:end);
    end
  end
end

if nargin < 1
  xfile = nnfile.files(fullfile(nnpath.nnet_root,'toolbox','nnet'),'all');
  for i=length(xfile):-1:1
    if any(xfile{i}(end-[1 0]) ~= '.m')
      xfile(i) = [];
    end
  end
end

% Multiple
if iscell(xfile)
  for i=1:length(xfile)
    nncode.fix_mhelp_links(xfile{i},mnames,params);
  end
  return
end

% Single
text = nntext.load(xfile);
change = false;
for i=1:length(text)
  ti = text{i};
  comment = (~isempty(ti)) && (ti(1)=='%');
  if comment
    ind = strfind(ti,'[[');
    for j=length(ind):-1:1
      start = ind(j);
      stop = strfind(ti(start:end),']]') + (start-1);
      if ~isempty(stop)
        stop = stop(1);
        name = (ti((start+2):(stop-1)));
        link = generate_link(name,mnames,params);
        if isempty(link)
          name
          xfile
          disp('UNRECOGNIZED LINK')
          keyboard
        else
          change = true;
          ti = [ti(1:(start-1)) link ti((stop+2):end)];
          text{i} = ti;
        end
      else
        disp('UNRECOGNIZED LINK START')
        keyboard
      end
    end
  end
end
if change
  nntext.save(xfile,text);
  disp(['Updated: ' nnpath.file2fcn(xfile)]);
end

function link = generate_link(name,mnames,params)
if nnstring.ends(lower(name),' function')
  name = lower(name);
  type = before_space(name);
  switch(type)
    case 'adapt'
      folder = 'nnadapt';
    case 'derivative'
      folder = 'nnderivative';
    case 'distance'
      folder = 'nndistance';
    case {'data division','division'}
      folder = 'nndivision';
      type = 'data division';
    case 'layer initialization'
      folder = 'nninitlayer';
    case 'network initialization'
      folder = 'nninitnet';
    case 'weight initialization'
      folder = 'nninitweight';
    case 'learning'
      folder = 'nnlearn';
    case 'net input'
      folder = 'nnnetinput';
    case 'network'
      folder = 'nnnetwork';
    case 'performance'
      folder = 'nnperformance';
    case 'plot'
      folder = 'nnplot';
    case 'processing'
      folder = 'nnprocess';
    case {'search','line search'}
      folder = 'nnsearch';
      type = 'line search';
    case 'topology'
      folder = 'nntopology';
    case 'training'
      folder = 'nntrain';
    case 'transfer'
      folder = 'nntransfer';
    case 'weight'
      folder = 'nnweight';
    otherwise
      link = '';
      disp('UNRECOGNIZED FUNCTION TYPE');
      return;
  end
  if ~exist(['nnet/' folder],'dir')
    link = '';
    disp('UNRECOGNIZED FOLDER')
    return
  end
  link = create_link([type ' function'],folder);
elseif nnstring.starts(name,'nnparam.') || nnstring.starts(name,'param.')
  param = after_dot(name);
  if ~isempty(nnstring.first_match(param,params))
    link = create_link(param,['nnparam.' param]);
  else
    link = '';
    disp('UNRECOGNIZED PARAMETER')
    return
  end
elseif isnnetfunction(lower(name),mnames)
  name = lower(name);
  link = create_link(name,name);
else
  link = '';
end

function link = create_link(text,location)
link = ['<a href="matlab:doc ' location '">' text '</a>'];

function flag = isnnetfunction(name,mnames)
for i=1:length(mnames)
  if strcmp(name,mnames{i})
    flag = true;
    return
  end
end
flag = false;

function x = after_dot(x)
i = find(x=='.',1);
x = x((i+1):end);

function x = before_space(x)
i = find(x == ' ',1,'last');
x = x(1:(i-1));

