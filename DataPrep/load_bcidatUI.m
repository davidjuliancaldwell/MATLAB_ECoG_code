function [signals, states, parameters, filepath] = load_bcidatUI (basedir)
% function [signals, states, parameters] = load_bcidatUI (basedir)
%
% basedir, directory to begin UI
%
    if (~exist('basedir','var'))
%         mydir = myGetenv('subject_dir');
%         
%         if (~isempty(mydir))
%             basedir = mydir;
%         else
            basedir = pwd;
%         end
    end

   saveDir = pwd;
   cd (basedir);
   
   [fname, fpath] = uigetfile('*.dat', 'Select a BCI2K dat file');
   
   filepath = [fpath '\' fname];
   
   [signals, states, parameters] = load_bcidat(filepath);
   
   cd(saveDir);
end
    