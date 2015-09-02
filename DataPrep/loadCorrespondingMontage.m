function [Montage, montageFilepath] = loadCorrespondingMontage(bci2000Filepath)
    montageFilepath = strrep(bci2000Filepath, '.dat', '_montage.mat');
    
    if (~exist(montageFilepath, 'file'))
        error ('assumed montage file does not exist: %s', montageFilepath)
    else
        load(montageFilepath)
    end
    
    if (~exist('Montage', 'var'))
        error ('a variable named Montage was not included in the assumed montage file: %s', montageFilepath);
    end
end