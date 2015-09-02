%% myGetenv.m
%  jdw
%
% Changelog:
%   28APR2011 - originally written
%
% This is a helper function that retrieves environment variables, but if
% those environment variables are undefined, it runs a bci workgroup
% specific environment setup script in an effort to define those variables.
% To use this function, it is necessary that you have a file somewhere on
% your matlab path called setupEnvironment.m that defines workspace
% specific environment variables.  See setupEnvironment.m.example for an
% example of what this file should look like.
%
% Parameters:
%   name - the name of the environment variable to get
%
% Return Values:
%   value - the value of the environment variable corresponding to name
%
function value = myGetenv(name)
    value = getenv(name);
    
    if (length(value) < 1)
        if (exist('setupEnvironment.m', 'file') == 2)
            setupEnvironment;
            value = getenv(name);    
        else
            error(['The getting and setting of bci group environment '...
                   'variables requires that you have a m-file on your '...
                   'path called setupEnvironment.m that sets both '...
                   'matlab_devel_dir and subject_dir corresponding '...
                   'to your environment settings.  See setupEnvironment.m.example']);
        end
    end
end