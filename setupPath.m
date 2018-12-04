% automatically set up path for bci code base
function setupPath

setupEnvironment;

codebase = getenv('gridlab_dir');
subj = getenv('subject_dir');
out = getenv('OUTPUT_DIR');
sharedCode = getenv('shared_code_dir');

%     extbase = getenv('gridlab_ext_dir');
%     home = getenv('home_dir');

% add bci2k root and tools to path
%     addToPath(fullfile(extbase, 'bci2k'));
%     addToPath(genpath(fullfile(extbase, 'bci2k', 'tools')));

% add all dataprep / experiment / siganal / visualization folders to
% path
addToPath(fullfile(codebase)); %modified 8/19/2015 to make sure right setupPath and setupEnvironment is added
addToPath(genpath(fullfile(codebase, 'DataPrep')));
addToPath(genpath(fullfile(codebase, 'Output')));
addToPath(genpath(fullfile(subj))); % 11-16-2015 DJC to account for changing path of output and subject to D drive
addToPath(genpath(fullfile(out))); % 11-16-2015

addToPath(fullfile(codebase, 'Experiment')); % don't add _ALL_ the
%     experiment ones, because we have lots of reused-but-changed-slightly
%     code in them.  that makes problems.
addToPath(fullfile(codebase, 'Experiment', 'FunctionalScreening'));
addToPath(fullfile(codebase, 'Experiment', 'DMN_BCI')); % DJC 6-11-2014
%  addToPath(genpath(fullfile(codebase, 'Experiment', 'Proprioception'))); % DJC 7-2-2014
addToPath(genpath(fullfile(codebase, 'Experiment', 'KurtConnectivity'))); % DJC 8-12-2015
addToPath(genpath(fullfile(codebase, 'Experiment', 'amHG'))); % DJC 12-4-2015
addToPath(genpath(fullfile(codebase, 'SigAnal')));
addToPath(genpath(fullfile(codebase, 'Experiment', 'Subdermal_QuickScreen'))); % DJC 7-22-2015
addToPath(genpath(fullfile(codebase, 'Visualization')));
addToPath(genpath(fullfile(codebase, 'Experiment', 'RJB_Inference'))); % DJC 8-1-2014
addToPath(genpath(fullfile(codebase, 'Experiment', 'BetaTriggeredStim'))); %DJC 7-21-2015
rmpath(genpath(fullfile(codebase,'Experiment','BetaTriggeredStim','old'))); % DJC 8-27-2015 - get rid of shadowed ones that aren't helping
rmpath(genpath(fullfile(codebase,'Experiment','BetaTriggeredStim','JDOcode'))); % DJC 8-27-2015 - same as above 
rmpath(genpath(fullfile(codebase,'Experiment','BetaTriggeredStim','scripts','V1'))); % DJC 8- 27 - same as above
addToPath(genpath(fullfile(codebase, 'BetaTriggeredStim')));
addToPath(genpath(fullfile(codebase, 'Experiment','LarryStimulation'))); % 10-28-2015 - added Larry Stim
addToPath(genpath(fullfile(codebase, 'FileExchange'))); %8-10-2015 DJC - adding file exchange toolboxes to this part
addToPath(genpath(fullfile(sharedCode, 'stimulation_spacing'))); %1-30-2017 
addToPath(genpath(fullfile(sharedCode, 'ResponseTimingAnalysis'))); %1-30-2017 
addToPath(genpath(fullfile(sharedCode, 'DBSanalysisCode'))); %1-30-2017 
addToPath(genpath(fullfile(sharedCode, 'ECoGAnalysisTools'))); %3-30-2017 
addToPath(genpath(fullfile(sharedCode, 'TDT2Matlab_conversion'))); %4-17-2017 
addToPath(genpath(fullfile(sharedCode, 'ElectrodeModeling'))); %11-17-2017
addToPath(genpath(fullfile(sharedCode, 'RHI'))); %11-17-2017
addToPath(genpath(fullfile(sharedCode, 'ElectrodeModeling'))); %1-30-2017 
addToPath(genpath(fullfile(sharedCode,'circstats-matlab')));
addToPath(genpath(fullfile(sharedCode,'phasemap')));
addToPath(genpath(fullfile(sharedCode,'measures-of-effect-size-toolbox')));
addToPath(genpath(fullfile(sharedCode,'permutationTest')));
addToPath(genpath(fullfile(sharedCode,'artifactRejection')));



rmpath(genpath(fullfile(codebase,'FileExchange','Toolboxes','distributionPlot'))); % DJC 1-8-2016, temporary to allow use of matlab 2015 hist function over the one in the distributionPlot toolbox

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