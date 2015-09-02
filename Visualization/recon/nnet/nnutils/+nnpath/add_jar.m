function add_jar(force)

% Copyright 2010 The MathWorks, Inc.

if ~usejava('swing'), return; end

if nargin < 2
  force = false;
end

if force || ~exist('com.mathworks.toolbox.nnet.matlab.nnTools','class')
   jcp = javaclasspath('-dynamic');
   jcp = [jcp { nnpath.nnet_jar }];
   warning('off','MATLAB:javaclasspath:jarAlreadySpecified');
   javaclasspath(jcp);
   warning('on','MATLAB:javaclasspath:jarAlreadySpecified');
 end
