function k = getKernel(name,cproto)

% Copyright 2012 The MathWorks, Inc.

if nargin < 2
  cproto = fullfile(nnpath.nnet_root,'toolbox','nnet','nnet','nnderivative','+nnGPU',[name '.cu']);
end

ext = parallel.gpu.ptxext;
ptx = fullfile(nnpath.nnet_root,'toolbox','nnet','nnet','nnderivative','+nnGPU',[name '.' ext]);
k = parallel.gpu.CUDAKernel(ptx,cproto);

