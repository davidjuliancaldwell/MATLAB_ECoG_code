%% Helper function to help user setup their unique environment on a new machine

function setupEnvironmentHelper

if ~exist ('setupEnvironment', 'file');
    fprintf ('Please choose path for development directory \n')
    matlabDevDir = uigetdir ('Please choose path for development directory');
    fprintf ('Please choose path for subject directory \n')
    subjectDir = uigetdir ('Please choose path for subject directory');

    setenv('matlab_devel_dir', matlabDevDir) 
    setenv('subject_dir', subjectDir) 
    
    setupEnvironmentMFile = fopen ('setupEnvironment.m', 'w');
    fprintf(setupEnvironmentMFile, 'function setupEnvironment \n \n');
    fprintf(setupEnvironmentMFile, 'setenv(''matlab_devel_dir'', ''%s'') \n', matlabDevDir);
    fprintf(setupEnvironmentMFile, 'setenv(''subject_dir'', ''%s'') \n', subjectDir);
    fclose (setupEnvironmentMFile);
else
    fprintf('It appears that setupEnvironment.m exists on your system. \n Delete and rerun if experiencing probelms.')
end

which setupEnvironment
%pause (5) % allows time for matlab to update the file and path