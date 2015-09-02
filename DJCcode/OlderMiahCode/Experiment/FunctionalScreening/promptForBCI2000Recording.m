function filepath = promptForBCI2000Recording(baseDir)
% function filepath = promptForBCI2000Recording(baseDir)
%
% opens a file selection dialog specific to BCI2000 (*.dat) and MATLAB
% (*.mat) filetypes

    if(~exist('baseDir', 'var'))        
        baseDir = myGetenv('subject_dir');
    end
    
    currentDir = pwd;

    try
        cd(baseDir);
        [name,path] = uigetfile('*.dat;*.mat','MultiSelect', 'off');
    catch
        cd(currentDir);
        filepath = '';
        return;
    end

    cd(currentDir);

    filepath = fullfile(path,name);
end
