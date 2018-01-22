function nn_cleanup(path)
%NN_CLEANUP Remove non-check-in files and prepare check-in files.

% Copyright 2010-2011 The MathWorks, Inc.

deleteFiles = {...
  'nnet.mif', ... % Toolbox configuration
  'mcc.xml',... % Generated file
  'mcc.enc',... % Generated file
  'MODULE_DEPENDENCIES',... % Java configuration
  'TEST_REQUIREMENTS.xml',... % smoke test file
  'issmoke.xml',... % smoke test file
  'enabled.txt',... % smoke test file
  'depends.xml',... % test file
  'chart',... % test file
  'Thumbs.db',... % Windows thumbnail file
  '.DS_Store'... % Mac OS folder info file
  };

deleteExtensions = {'.asv'};

deleteDirectories = {'CVS','autopilot','singledisplay','ja','html'};

deletePathFiles = {fullfile('toolbox','nnet','Contents.m')};

d = dir(path);
for i=1:length(d)
  name = d(i).name;
  if d(i).isdir
    % Meta Directories
    if strcmp(name,'.') || strcmp(name,'..')
      continue;
    % Delete Directories
    elseif ~isempty(nnstring.first_match(name,deleteDirectories))
      disp(['Deleting: ' fullfile(path,name)])
      rmdir(fullfile(path,name),'s');
    % Recurse Directories
    else
      nn_cleanup(fullfile(path,name));
    end
  else
    fullname = fullfile(path,name);
    found = false;
    for j=1:length(deletePathFiles)
      if nnstring.ends(fullname,deletePathFiles{j})
        disp(['Deleting: ' fullfile(path,name)])
        delete(fullfile(path,name));
        found = true;
        break;
      end
    end
    if found, break; end
    
    % Delete Invisible Files
    if name(1) == '.'
      disp(['Deleting: ' fullfile(path,name)])
      delete(fullfile(path,name));
    % Delete Files
    elseif ~isempty(nnstring.first_match(name,deleteFiles))
      disp(['Deleting: ' fullfile(path,name)])
      delete(fullfile(path,name));
    % Delete Extensions
    else
      for j=1:length(deleteExtensions)
        if nnstring.ends(name,deleteExtensions{j})
          disp(['Deleting: ' fullfile(path,name)])
          delete(fullfile(path,name));
          break;
        end
      end
    end
  end
end
