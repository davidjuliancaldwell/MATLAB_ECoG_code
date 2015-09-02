%% File handling helper function
% Asks if user wants to reuse existing file from subject. if not, user
% prompted for new file. JDO 8/2013
%[filepath, subjid] = fileHandling (subjid, filename) 
% filename is previously used file of a given subject

function [filepath, subjid, filename] = fileHandling 

% calls function to help identify the subject and development directories
if ~exist ('setupEnvironment', 'file')
    setupEnvironmentHelper;
end

setupEnvironment; % runs the script created in step above, done for legacy reasons. 

if exist ('currentSubject.mat', 'file');
    load ('currentSubject.mat', 'subjid', 'filepath', 'filename'); %open prior path info if present.
end

%setting variables for use in function
repeat = 'n';
subjRepeat = 'n';

% asking for user input to use same subject and filename, or just same
% subject. 
if exist ('subjid', 'var');
    if exist ('filename', 'var');
        repeat = input (strcat('Use same file ...', filename, ' ?  [y]/n : '), 's');
        if isempty(repeat);
            repeat = 'y';
        end;
    end;
    
    if repeat ~= 'y';        
        subjRepeat = input (strcat('Use same subject...', subjid, ' ?  [y]/n : '), 's');
        if isempty(subjRepeat);
            subjRepeat = 'y';
        end;
    end;
end;

if subjRepeat == 'y';
    filepath = promptForBCI2000Recording(strrep ([myGetenv('subject_dir') filesep subjid], [filesep filesep], filesep)); %filesep replacement used in case subject_dir has a trailing filesep
    subjid = extractSubjid(filepath); %from QuickScreen_StimulusPresentation_J
end

if subjRepeat ~= 'y';
    if repeat ~= 'y';
        filepath = promptForBCI2000Recording; %from QuickScreen_StimulusPresentation_J
        subjid = extractSubjid(filepath); %from QuickScreen_StimulusPresentation_J
    end;
end;

[~, filename, ~] = fileparts(filepath); %reading filename to save to subject info file for next iteration
fprintf('Using file: %s \n', filename)

save ('currentSubject.mat', 'subjid', 'filepath', 'filename'); % save subject info in file for next iteration.
