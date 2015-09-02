%% gotoSubject.m
%  jdw - 28APR2011
%
% Changelog:
%   28APR2011 - originally written
%   36MAR2012 - eliminated encoding of subject id
%
% This is a simple utility script that, given a subject id
% will change directories to the scripts directory for that subject id.
% Note that the scripts directory (as created in setupSubject) is contained
% within a directory structure named with the encoded subject id.
%
% Parameters:
%   subjID - the subject id 
%
% Return Values:
%

function gotoSubject(subjID)
    root = myGetenv('subject_dir');    

    cd(strcat(root, '\', subjID));
end