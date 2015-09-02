%% getSubjDir.m
%  tmb - 18MAY20111
%
% Changelog:
%   18MAY2011 - originally written
%   02FEB2012 - changed to not encode subject id (ie. fc9643 would be
%   passed instead of the unencoded subject id.  This is to support changes
%   away from any use of unencoded subject id's. ~JDW
%
% This is a simple utility script that, given a subject id (e.g. 123456)
% will return the subject directory associated with the subject code
%
% Parameters:
%   subjID - the subject id 
%
% Return Values:
%

function outDir = getSubjDir(subjID)
    root = myGetenv('subject_dir');    
%     pid = genPID(subjID);    

    outDir = (strcat(root, '\', subjID,'\'));
end