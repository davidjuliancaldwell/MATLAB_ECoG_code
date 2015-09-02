function undo_mhelp_links(xfile,mnames)
%UNDO_MHELP_LINKS Convert function links in bracketed references.

% Copyright 2010-2011 The MathWorks, Inc.

% Default is all toolbox dotm files
if nargin < 1
  xfile = nnfile.files(fullfile(nnpath.nnet_root,'toolbox','nnet'),'all');
  for i=length(xfile):-1:1
    if any(xfile{i}(end-[1 0]) ~= '.m')
      xfile(i) = [];
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
end

% Multiple
if iscell(xfile)
  for i=1:length(xfile)
    nncode.undo_mhelp_links(xfile{i},mnames);
  end
  return
end

% Single
LEFT = '<a href="matlab:doc ';
RIGHT = '</a>';
NETWORK = 'network/';

text = nntext.load(xfile);
change = false;
for i=1:length(text)
  ti = text{i};
  comment = find(ti=='%',1,'first');
  if ~isempty(comment)
    ind = strfind(ti((comment+1):end),LEFT);
    for j=length(ind):-1:1
      start = ind(j) + comment;
      stop = strfind(ti(start:end),RIGHT)+(start-1);
      if ~isempty(stop)
        stop = stop(1);
        match = lower(ti((start + length(LEFT)):(stop-1)));
        middle = strfind(match,'">');
        if ~isempty(middle)
          middle = middle(1);
          name1 = match(1:(middle-1));
          if nnstring.starts(name1,NETWORK)
            name1(1:length(NETWORK)) = [];
          end
          name2 = match((middle+2):end);
          if nnstring.starts(name2,NETWORK)
            name2(1:length(NETWORK)) = [];
          end
          if strcmp(name1,name2)
            name = name1;
            if isnnetfunction(name,mnames)
              change = true;
              ti = [ti(1:(start-1)) '[[' name ']]' ti((stop+length(RIGHT)):end)];
              text{i} = ti;
            end
          end
        end
      end
    end
  end
end
if change
  nntext.save(xfile,text);
  disp(['Updated: ' nnpath.file2fcn(xfile)]);
end

function flag = isnnetfunction(name,mnames)
name2 = ['network/' name];
for i=1:length(mnames)
  if strcmp(name,mnames{i}) || strcmp(name2,mnames{i})
    flag = true;
    return
  end
end
flag = false;
