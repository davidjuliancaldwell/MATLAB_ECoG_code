function [same,changed,moved,removed,added] = nn_diff_files(oldRoot,newRoot,deleteFiles)

% Copyright 2010-2011 The MathWorks, Inc.

same = {};
changed = {};
moved = {};
removed = {};
added = {};

if nargin < 3, deleteFiles = {}; end

oldFiles = nn_abs2rel_files(nn_nnet_files(oldRoot),oldRoot);
newFiles = nn_abs2rel_files(nn_nnet_files(newRoot),newRoot);

for i=1:length(deleteFiles)
  index = nnstring.first_match(deleteFiles{i},oldFiles);
  if isempty(index)
    disp(['Error, Delete file is missing: ' deleteFiles{i}]);
  end
  oldFiles(index) = [];
end

[kept,ind1,ind2] = intersect(oldFiles,newFiles);
oldFiles(ind1) = [];
newFiles(ind2) = [];

% Same & Changed
same = {};
changed = {};
i = 1;
for i=1:length(kept)
  file = kept{i};
  oldFile = nn_rel2abs_file(file,oldRoot);
  newFile = nn_rel2abs_file(file,newRoot);
  if nn_changed_file(oldFile,newFile)
    changed = [changed {file}];
  else
    same = [same {file}];
  end
end

% Moved
oldNames = nn_file_names(oldFiles);
newNames = nn_file_names(newFiles);
[uniqueOldNames,uoi] = unique(oldNames);
[uniqueNewNames,uni] = unique(newNames);
if length(uniqueOldNames) < length(oldNames)
  nonunique = 1:length(oldNames);
  nonunique(uoi) = [];
  for i=1:length(nonunique)
    name = oldNames{nonunique(i)};
    indices = nnstring.first_match(name,oldNames)';
    disp(' ')
    disp(['Error: Non-unique old file "' name '"'])
    for j=indices
      disp(['-> ' oldFiles{j}])
    end
  end
  return;
end
if length(uniqueNewNames) < length(newNames)
  nonunique = 1:length(newNames);
  nonunique(uni) = [];
  for i=1:length(nonunique)
    name = newNames{nonunique(i)};
    indices = nnstring.first_match(name,newNames)';
    disp(' ')
    disp(['Error: Non-unique new file "' name '"'])
    for j=indices
      disp(['-> ' newFiles{j}])
    end
  end
  return;
end
[moved,oldi,newi] = intersect(oldNames,newNames);
oldFiles(oldi) = [];
newFiles(newi) = [];

% Removed
removed = sort([delete; oldFiles]);

% Added
added = newFiles;
