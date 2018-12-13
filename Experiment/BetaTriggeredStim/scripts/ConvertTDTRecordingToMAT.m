% this script collects all of the records in a tdt data tank and converts
% it to a mat file
if (exist('myGetenv', 'file'))
    start = myGetenv('subject_dir');    
    if (isempty(start))
        start = pwd;
    end
else
    start = pwd;
end

rawpath = uigetdir(start, 'select a TDT data BLOCK');
[tankpath, blockname] = fileparts(rawpath);
outpath = uigetdir(tankpath, 'select an output directory for MAT file');

mTDT2MAT(tankpath, blockname, outpath);




