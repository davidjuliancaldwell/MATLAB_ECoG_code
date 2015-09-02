function res = hasGPU
    res = exist('gpuArray', 'file') > 0;
end