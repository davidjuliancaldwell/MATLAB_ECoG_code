% here is an example m file of what setupEnvironment.m should look like on
% your machine.  Make sure to change the values of the environment
% variables below to reflect your workspace settings.
if ispc
    setenv('matlab_devel_dir', 'C:\Users\djcald.CSENETID\Code');
    setenv('gridlab_dir', 'C:\Users\djcald.CSENETID\Code');
    setenv('shared_code_dir', 'C:\Users\djcald.CSENETID\SharedCode');
    setenv('subject_dir', 'C:\Users\djcald.CSENETID\Data\Subjects');
    setenv('dbs_subject_dir','G:\My Drive\GRIDLabDavidShared\DBS\');
    setenv('OUTPUT_DIR', 'C:\Users\djcald.CSENETID\Data\Output');
    
elseif ismac
    setenv('matlab_devel_dir', '/Users/djcald/MATLAB/Code');
    setenv('gridlab_dir', '/Users/djcald/MATLAB/Code');
    setenv('shared_code_dir', '/Users/djcald/MATLAB/');
    setenv('subject_dir', '/Users/djcald/Subjects/');
    setenv('dbs_subject_dir','/Google\ Drive \File \Stream/My \Drive/GRIDLabDavidShared/DBS');
    setenv('OUTPUT_DIR', '/Users/djcald/MATLAB/Output');
    
end