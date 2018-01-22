function [ setupstruct ] = setupAll( filename )
%SETUPALL Takes in an environmental setup file
%   And sets the root and paths
%   Ex: setupAll('1')

    origpath = pwd();
%     setenv('bcimatlabpath', origpath);
    addpath([origpath '/' 'setupAll_depends']);

%% Read init file
    if(nargin < 1 || ~ischar(filename))
        error('Please input name of setup file! Ex: setupAll(''1'');');
    end
    
    if(exist([filename '.ini'], 'file') ~= 2)
        error(['Setup file of' filename 'does not exist!']);
    end
    
    setupcontents = inifile([filename '.ini'], 'readall');
    
%% Setup modules
    %%%% NATIVE MODULES NOT REQUIRING SETUP, ADDPATH ONLY
    appdir = selectonly(setupcontents, 'application', 'modules', 'root');
    modulenames = selectonly(setupcontents, 'application', 'modules', 'names');
    modulenames = regexp(modulenames, ',', 'split');
    for iter = 1:numel(modulenames)
        addpath_top_recurse(origpath, [appdir '/' modulenames{iter}]);
    end

    %%%% CONTRIB MODULES REQUIRING SETUP
% Modules are packages requiring dedicated setup files, and setupAll()
% will try to run their respective [modulename]setup.m files
    contribsetupdir = selectonly(setupcontents, 'application', 'contribs', 'setupmfiles');
    contribsetupnames = selectonly(setupcontents, 'application', 'contribs', 'names');
    contribsetupnames = regexp(contribsetupnames, ',', 'split');
    contribdir = selectonly(setupcontents, 'application', 'contribs', 'root');    
    if(~istoplevel(contribdir))
        contribdir = [origpath '/' contribdir];
    end
    
    addpath_top(origpath, contribsetupdir);
    
    for iter = 1:numel(contribsetupnames)
        if(exist([contribsetupnames{iter} 'setup.m'], 'file') == 2)
            eval([contribsetupnames{iter} 'setup(''' contribdir ''')']);
        else
            warning([contribsetupnames{iter} 'setup.m not found in contrib path.'])
            warning(['Adding', contribsetupnames{iter},'to path instead.'])
            addpath_recurse([contribdir '/' contribsetupnames{iter}])
        end
    end
    
    %%%% OTHER ADD_THE_DIR CONTRIB MODULES
    % Additionalscripts are simply dirs of scripts, and addpath() will be run
    additionaldir = selectonly(setupcontents, 'application', 'additional', 'root');
    additionalscripts = selectonly(setupcontents, 'application', 'additional', 'scriptdirs');
    additionalscripts = regexp(additionalscripts, ',', 'split');
    for iter = 1:numel(additionalscripts)
        addpath_top(origpath, [additionaldir '/' additionalscripts{iter}]);
    end
    
    %%%% MIAH COMPATIBILITY LAYER
    matlab_devel_dir = selectonly(setupcontents, 'application', 'miahcompatibility', 'matlab_devel_dir');
    if(~isempty(matlab_devel_dir))
        disp('Miah compatibility layer activated for matlab_devel_dir');
        if(~istoplevel(contribdir))
            matlab_devel_dir = strrep([origpath '/' matlab_devel_dir], '/', '\');
        else
            matlab_devel_dir = strrep(matlab_devel_dir, '/', '\');
        end
        setenv('matlab_devel_dir', matlab_devel_dir);
    end
    
%% Get data directory structure
    % Detect the root directory of data
    dataroot = selectonly(setupcontents, 'data', 'dataroot');
    if (~exist(dataroot, 'dir'))
        error('Data root path is invalid.');
    end
    
%% Get subject data

    % Detect subject data path
    datadir = selectonly(setupcontents, 'data', 'subjects', 'root');
    datadir = [dataroot '/' datadir];
    if (~exist(datadir, 'dir'))
        error('Subj data path is invalid.');
    end
    
    filenamelist = {};
    
    % Grab all the files in the allindirs
    dirgetall = selectonly(setupcontents, 'data', 'subjects', 'allindirs');
    if(~isempty(dirgetall))
        dirgetall = regexp(dirgetall, ',', 'split');
        % Gather all the files
        for iter = 1:numel(dirgetall)
            filenames = dir([datadir '/' dirgetall{iter}]);
            filenames = {filenames(~[filenames.isdir]).name};
            filenames = strcat(dirgetall{iter}, '/', filenames);
            filenamelist = [filenamelist filenames];
        end
    end
    
    % Grab some of the files in the someindirs where names match
        % Search for files in these locations, ...
    dirgetsome = selectonly(setupcontents, 'data', 'subjects', 'someindirs');
        % ... with these sort of file names
    dirgetnames = selectonly(setupcontents, 'data', 'subjects', 'namecontains');
    
    if(~(isempty(dirgetsome) || isempty(dirgetnames)))  
        dirgetsome = regexp(dirgetsome, ',', 'split');
        dirgetnames = regexp(dirgetnames, ',', 'split');

        % Gather all the files, but prune using name_contains()
        for iter = 1:numel(dirgetsome)
            filenames = dir([datadir '/' dirgetsome{iter}]);
            filenames = {filenames(~[filenames.isdir]).name};
            filenames = name_contains(filenames, dirgetnames);
            filenames = strcat(dirgetsome{iter}, '/', filenames);
            filenamelist = [filenamelist filenames];
        end
    end
    
    filenamelist = name_contains(filenamelist, '.dat');
    filenamelist = strcat(datadir, '/', filenamelist);

    %%%% OUTPUT TO STRUCT %%%%
    if(~isempty(filenamelist))
        setupstruct.subjects = filenamelist;
    else
        warning('No subject data specified! Are you just setting up paths?')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
%% Get recon directory if this is a recon run
    recondir = selectonly(setupcontents, 'data', 'recon', 'root');
    if(~isempty(recondir))
        recondir = [dataroot '/' recondir '/'];
        recondir = strrep(recondir, '/', '\'); % necessary for compatibility

        reconsubj = selectonly(setupcontents, 'data', 'recon', 'reconsubj');
        if(~isempty(reconsubj))
            reconsubj = regexp(reconsubj, ',', 'split');
        end
        
        %%%% OUTPUT TO STRUCT %%%%
        setupstruct.recondir = recondir;
        if(~isempty(reconsubj))
            setupstruct.reconsubj = reconsubj;
            %%%%%% add a question here later
            setenv('subject_dir', recondir);
        else
            warning('No recon subject specified!')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%% 
    else
        warning('Warning: No recon directory found. Skipping section...')
    end

%% Get anatomical references like talairach, mni
    anatdir = selectonly(setupcontents, 'data', 'references', 'root');
    if(~isempty(anatdir))
        anatdir = [dataroot '/' anatdir];
        if (~exist(anatdir, 'dir'))
            error('Anatomical reference path is invalid.');
        end

        % Grab talairach reference
        tlrcdir = selectonly(setupcontents, 'data', 'references', 'talairach');
        if(~isempty(tlrcdir))
            tlrcdir = regexp(tlrcdir, ',', 'split');
            % Gather all the files
            if numel(tlrcdir) > 1
                warning('More than 1 talairach reference found, using only the first...');
            end
            talairachlocation = [anatdir '/' tlrcdir{1}];
        end
        
        %%%% OUTPUT TO STRUCT %%%%
        if(exist('talairachlocation', 'var'))
            setupstruct.talairach = talairachlocation;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        warning('Warning: No anatomic reference found. Skipping section...')
    end
    
    
end








%% Parse init file by going down the rabbit hole
function [ selection ] = selectonly( varargin )
    if( nargin < 2)
        error('Please input the cell and the string(s) to match');
    end
    
    selection = varargin{1};
    
    % recursively go down the rabbit hole
    % i.e. selectonly(setupcontents, 'application', 'modules')
    % select for only rows with "application", then with "modules"
    for iter = 2:nargin
        selection = selection(any(strcmp(selection, varargin{iter}), 2), :);
        if(size(selection, 1) == 1) % if down to one element, then un-cell
            selection = selection{end};
        end
    end
end


%% Identify if top level directory
function [ toplevel ] = istoplevel( path )
    if(any(regexp(path, '^\w:[/\\]')) || any(regexp(path, '^/')))
        toplevel = 1;
    else
        toplevel = 0;
    end
end


%% addpath and check if top level directory
function [ ] = addpath_top( basepath, addedpath )
    if(istoplevel(addedpath))
        addpath(addedpath);
    else
        addpath( [ basepath '/' addedpath ] );
    end
end


%% addpath_recurse and check if top level directory
function [ ] = addpath_top_recurse( basepath, addedpath )
    if(istoplevel(addedpath))
        addpath_recurse(addedpath);
    else
        addpath_recurse( [ basepath '/' addedpath ] );
    end
end
