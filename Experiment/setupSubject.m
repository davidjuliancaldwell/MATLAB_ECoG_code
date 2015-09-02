%% setupSubject.m
%  jdw 28APR2011
%
% Changelog:
%   28APR2011 - originally written
%
% This function automatically generates a new directory structure within
% the directory defined by the subject_dir environment variable.  It will
% generate the following directory structure.
%
% -> pid
%     -> prog
%     -> data
%     -> results
%     -> presentation
%     -> resource
%
% Parameters:
%   subjID - the subject id to use as the basis for PID generation
%
% Return Values:
%

function setupSubject(subjID)
    root = myGetenv('subject_dir');    
    pid = genPID(subjID);    

    mkdir(strcat(root, '\', pid));
    mkdir(strcat(root, '\', pid, '\prog'));
    mkdir(strcat(root, '\', pid, '\data'));
    mkdir(strcat(root, '\', pid, '\results'));
    mkdir(strcat(root, '\', pid, '\presentation'));
    mkdir(strcat(root, '\', pid, '\resource'));
   
    gotoSubject(subjID);
end