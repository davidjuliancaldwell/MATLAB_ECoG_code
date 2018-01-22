%%
% Author: JDW
%
% This is a simple script to generate talairach electrode locations, hmat
% values, and brodmann areas for legacy subjects.  To use, change the value
% of sid to correspond to the subject for which you wish to generate these
% scripts and run.  Be advised, trodesToTalairach is interactive and cannot
% run headless.

%% parameters
% sid = 'a3da50';
sid = input('Enter a subject ID: ','s');

if (isempty(sid))
    error('must enter a subject ID to run script.');
end

generateTalSpaceTrodesAndLabels_func(sid);