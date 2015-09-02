function create_submit(old,new)
%CREATE_SUBMIT Prepare submission and create change, edit and submit files.

% Copyright 2010-2011 The MathWorks, Inc.

if nargin < 1, old = fullfile(filesep,'NNET6'); end
if nargin < 2, new = fullfile(filesep,'NNET7'); end

clc
[files1,names1] = nn_prepare(old,'Old');
[files2,names2] = nn_prepare(new,'New');
numOld = length(files1);
numNew = length(files2);
disp(['Old files: ' num2str(numOld)])
disp(['New files: ' num2str(numNew)])
disp(' ')

% Unmoved Files
changed1 = [];
changed2 = [];
same1 = [];
same2 = [];
for i=1:length(files1)
  file1 = files1{i};
  ind = nnstring.first_match(file1,files2);
  if ~isempty(ind)
    if nn_same_files(fullfile(old,file1),fullfile(new,file1));
      same1 = [same1 i];
      same2 = [same2 ind];
    else
     changed1 = [changed1 i];
     changed2 = [changed2 ind];
    end
  end
end
sameFiles = files1(same1);
sameNames = files2(same1);
changedFiles = files1(changed1);
changedNames = names1(changed1);
files1([same1 changed1]) = [];
names1([same1 changed1]) = [];
files2([same2 changed2]) = [];
names2([same2 changed2]) = [];

if length([files1; sameFiles; changedFiles]) ~= numOld, error(message('nnet:NNDev:NNDev')); end
if length([files2; sameFiles; changedFiles]) ~= numNew, error(message('nnet:NNDev:NNDev')); end

% Deleted Files
oldInd = [];
for i=1:length(files1)
  name1 = names1{i};
  if strcmp(name1,'Contents.m')
    oldInd = [oldInd i];
  else
    ind = nnstring.first_match(name1,names2);
    if isempty(ind)
      oldInd = [oldInd i];
    end
  end
end
deletedFiles = files1(oldInd);
deletedNames = files1(oldInd);
files1(oldInd) = [];
names1(oldInd) = [];

if length([files1; sameFiles; changedFiles; deletedFiles]) ~= numOld, error(message('nnet:NNDev:NNDev')); end
if length([files2; sameFiles; changedFiles]) ~= numNew, error(message('nnet:NNDev:NNDev')); end

% New Files
newInd = [];
for i=1:length(files2)
  name2 = names2{i};
  if strcmp(name2,'Contents.m')
    newInd = [newInd i];
  else
    ind = nnstring.first_match(name2,names1);
    if isempty(ind)
      newInd = [newInd i];
    end
  end
end
newFiles = files2(newInd);
newNames = files2(newInd);
files2(newInd) = [];
names2(newInd) = [];

if length([files1; sameFiles; changedFiles; deletedFiles]) ~= numOld, error(message('nnet:NNDev:NNDev')); end
if length([files2; sameFiles; changedFiles; newFiles]) ~= numNew, error(message('nnet:NNDev:NNDev')); end

% Moved Files
movedInd1 = [];
movedInd2 = [];
for i=1:length(files1)
  name1 = names1{i};
  ind1 = nnstring.first_match(name1,names2);
  ind2 = nnstring.first_match(name1,names1);
  if (numel(ind1)==1) && (numel(ind2)==1)
    movedInd1 = [movedInd1 i];
    movedInd2 = [movedInd2 ind1];
  end
end
movedFromFiles = files1(movedInd1);
movedFromNames = names1(movedInd1);
movedToFiles = files2(movedInd2);
moveToNames = files2(movedInd2);
files1(movedInd1) = [];
names1(movedInd1) = [];
files2(movedInd2) = [];
names2(movedInd2) = [];

% Moves with Multiple Interpretations, Delete & Create
deletedFiles = [deletedFiles; files1]; files1 = {};
newFiles = [newFiles; files2]; files2 = {};

disp(['Unchanged files: ' num2str(length(same1))])
disp(['Changed files: ' num2str(length(changedFiles))])
disp(['Deleted files: ' num2str(length(deletedFiles))])
disp(['New files: ' num2str(length(newFiles))])
disp(['Moved files: ' num2str(length(movedFromFiles))])
disp(' ')

if length([files1; sameFiles; changedFiles; deletedFiles; movedFromFiles]) ~= numOld, error(message('nnet:NNDev:NNDev')); end
if length([files2; sameFiles; changedFiles; newFiles; movedToFiles]) ~= numNew, error(message('nnet:NNDev:NNDev')); end

% Check that all files are accounted for
if length(files1) > 0
  error(message('nnet:nncode_create_submit:OldFileNotProcessed'));
end
if length(files2) > 0
  error(message('nnet:nncode_create_submit:NewFilesNotProcessed'));
end

% Update copyright
for i=1:length(changedFiles)
  nn_update_copyright(fullfile(new,changedFiles{i}));
end
for i=1:length(movedToFiles)
  nn_update_copyright(fullfile(new,movedToFiles{i}));
end
for i=1:length(newFiles)
  nn_update_copyright(fullfile(new,newFiles{i}));
end

% Prepare for edit/submit files
changedFiles = nn_add_matlab(changedFiles);
movedFromFiles = nn_add_matlab(movedFromFiles);
movedToFiles = nn_add_matlab(movedToFiles);
deletedFiles = nn_add_matlab(deletedFiles);
newFiles = nn_add_matlab(newFiles);

% Create change script
text = {};
text = [text {'sandbox = fullfile(''S:'',''Sandbox_LTC'');'}];
text = [text {'newcode = fullfile(''S:'',''NNET7'');'}];
text = [text {''}];
for i=1:length(changedFiles)
  text = [text {['nn_delete(fullfile(sandbox,''' changedFiles{i} '''));']}];
end
for i=1:length(movedFromFiles)
  text = [text {['nn_delete(fullfile(sandbox,''' movedFromFiles{i} '''));']}];
end
for i=1:length(deletedFiles)
  text = [text {['nn_delete(fullfile(sandbox,''' deletedFiles{i} '''));']}];
end
for i=1:length(changedFiles)
  text = [text {['nn_copy_file(fullfile(newcode,''' changedFiles{i} '''),fullfile(sandbox,''' changedFiles{i} '''));']}];
end
for i=1:length(movedFromFiles)
  text = [text {['nn_copy_file(fullfile(newcode,''' movedToFiles{i} '''),fullfile(sandbox,''' movedToFiles{i} '''));']}];
end
for i=1:length(newFiles)
  text = [text {['nn_copy_file(fullfile(newcode,''' newFiles{i} '''),fullfile(sandbox,''' newFiles{i} '''));']}];
end
nn_savetext(fullfile(filesep,'change.m'),text);

% Create edit file
editText = [ changedFiles; movedFromFiles; deletedFiles ];
nn_savetext(fullfile(filesep,'edit.txt'),editText);

% Create submit file
for i=1:length(changedFiles)
  file = changedFiles{i};
  if nn_is_binary_ext(nn_file_ext(file)), file = ['-b ' file]; end
  changedFiles{i} = file;
end
for i=1:length(movedFromFiles)
  file = movedFromFiles{i};
  file = ['-r ' file ' ' movedToFiles{i}];
  movedFromFiles{i} = file;
end
for i=1:length(deletedFiles)
  file = deletedFiles{i};
  file = ['-d ' file];
  deletedFiles{i} = file;
end
for i=1:length(newFiles)
  file = newFiles{i};
  if nn_is_binary_ext(nn_file_ext(file)), file = ['-b ' file]; end
  newFiles{i} = file;
end
submitText = [ changedFiles; movedFromFiles; deletedFiles; newFiles ];
nn_savetext(fullfile(filesep,'submit.txt'),submitText);

function [files,names] = nn_prepare(path,version)

nn_cleanup(path);
nnetPaths = {...
  fullfile(path,'toolbox','nnet')
  fullfile(path,'java','src','com','mathworks','toolbox','nnet')
  fullfile(path,'test','smoke','Neural_Network_Toolbox')
  fullfile(path,'test','toolbox','nnet')
  };
files = nn_files(nnetPaths,'all');

clip = length(path)+2;
for i=1:length(files)
  files{i} = files{i}(clip:end);
end

names = nn_file_names(files);

disp(' ')
disp(['Non-Unique Filenames - ' version])
disp('==========================')
nonUnique = false;
calledNames = names;
calledInd = 1:length(names);
for i=length(calledNames):-1:1
  name = calledNames{i};
  if nnstring.ends(name,'.png')
    calledNames(i) = [];
    calledInd(i) = [];
  elseif strcmp(name,'Contents.m')
    calledNames(i) = [];
    calledInd(i) = [];
  end
end
[uniqueNames1,uniqueInd,allInd] = unique(calledNames);
for i=1:length(uniqueInd)
  if sum(allInd == i) > 1
    nonUnique = true;
    j = find(allInd == i);
    disp(uniqueNames1{i})
    for k=j'
      disp(['  ' files{calledInd(k)}])
    end
  end
end
if ~nonUnique, disp('(none)'), end
disp(' ')

% Unrecognized extensions
for i=1:length(files)
  ext = nn_file_ext(files{i});
  if ~(nn_is_binary_ext(ext) || nn_is_text_ext(ext))
    disp(' ')
    disp(files{i})
    nnerr.throw(['Unrecognized extension: ' ext])
  end
end

function files = nn_add_matlab(files)
for i=1:length(files)
  files{i} = fullfile('matlab',files{i});
end
