% automatically set up path for bci code base
% modified for proprioception folder from Jared by DJC 7/2014
function setupPath

    setupEnvironment;
    
    codebase = getenv('gridlab_dir');
%     extbase = getenv('gridlab_ext_dir');
%     home = getenv('home_dir');
    
    % add bci2k root and tools to path
%     addToPath(fullfile(extbase, 'bci2k'));
%     addToPath(genpath(fullfile(extbase, 'bci2k', 'tools')));
    
    % add all dataprep / experiment / siganal / visualization folders to
    % path
    addToPath(genpath(fullfile(codebase, 'Proprioception')));
    %addToPath(fullfile(codebase, 'Experiment')); % don't add _ALL_ the
%     experiment ones, because we have lots of reused-but-changed-slightly
%     code in them.  that makes problems.
   % addToPath(fullfile(codebase, 'Experiment', 'FunctionalScreening'));
    %addToPath(fullfile(codebase, 'Experiment', 'DMN_BCI')); % DJC 6-11-2014
    %addToPath(genpath(fullfile(codebase, 'Experiment', 'Proprioception'))); % DJC 7-2-2014
    addToPath(genpath(fullfile(codebase, 'scripts')));
    %addToPath(genpath(fullfile(codebase, 'Visualization')));
   
    
%     % add select subfolders folders from external folder to path
%     addToPath(fullfile(extbase, 'External'));
%     addToPath(fullfile(extbase, 'External', 'spm8'));
%     addToPath(genpath(fullfile(extbase, 'External', 'libsvm-3.17', 'matlab')));
%     addToPath(genpath(fullfile(extbase, 'External', 'mrmr')));
    
%     % add my custom code to the path 
%     addToPath(genpath(getenv('env_dir')));
% %     addToPath(genpath(getenv('sandbox_dir')));
%     
% %     % add the ptmk3 library to the path
% %     addToPath('d:\research\code\pmtk');
% %     curDir = pwd;
% %     initPmtk3;
% %     cd(curDir);
    
    tgt = fullfile(getenv('home_dir'), 'pathdef.m');
    result = savepath(tgt);
    
    if result == 0
        fprintf('success saving path to : %s\n', tgt);
    else
        warning('unable to save path to : %s\n', tgt);
    end
end

function addToPath(toadd)
    fprintf('adding %s to path\n', toadd);
    addpath(toadd);    
end