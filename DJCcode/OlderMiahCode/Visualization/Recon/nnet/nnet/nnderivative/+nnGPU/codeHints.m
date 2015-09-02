function hints = codeHints(hints)

% Copyright 2012 The MathWorks, Inc.

MAX_MASKS = 3;

% C Precision
switch hints.precision
  case 'single', cPrecision = 'float';
  case 'double', cPrecision = 'double';
end

% PERFORMANCE KERNEL

perfsProto = [ ...
  'PRECISION *,' ...
  'const PRECISION *,' ...
  'const PRECISION *, const PRECISION *, const PRECISION *, const PRECISION *, PRECISION *,' ...
  'const PRECISION *, const PRECISION *, const signed char * const,' ...
  'const long long, const long long, const long long,' ...
  'const long long *, const long long, const PRECISION *, const long long,' ...
  'const long long'];
perfsProto = strrep(perfsProto,'PRECISION',cPrecision);
hints.perfsKernel = nnGPU.getKernel(['perfs_' hints.precision],perfsProto);

if (hints.perfsKernel.MaxThreadsPerBlock >= 1024)
  hints.perfsBlockWidth = 32;
elseif (hints.perfsKernel.MaxThreadsPerBlock >= 256)
  hints.perfsBlockWidth = 16;
else
  hints.perfsBlockWidth = 8;
end
hints.perfsGridSize = ceil(hints.Q / hints.perfsBlockWidth);
hints.perfsKernel.ThreadBlockSize = [hints.perfsBlockWidth hints.perfsBlockWidth];
hints.perfsKernel.GridSize = hints.perfsGridSize;
hints.perfsKernel.SharedMemorySize = 2*(hints.perfsBlockWidth^2)*hints.valSize + hints.sizeHints;

% ALLOCATE PERFORMANCE RESULT
Perfs_and_N = zeros(2*MAX_MASKS,hints.perfsGridSize,hints.precision);
if isempty(Perfs_and_N)
  % GPUs do not like empty matrices
  Perfs_and_N = zeros(2*MAX_MASKS,1,hints.precision);
end
hints.Perfs_and_N = gpuArray(Perfs_and_N);

% Y KERNEL
yProto = [ ...
  'PRECISION *, PRECISION *,'...
  'const PRECISION *,' ...
  'const PRECISION *, const PRECISION *, const PRECISION *, const PRECISION *,' ...
  'const long long, const long long, const long long,' ...
  'const long long *, const long long, const PRECISION *, const long long'];
yProto = strrep(yProto,'PRECISION',cPrecision);
hints.yKernel = nnGPU.getKernel(['yy_' hints.precision],yProto);

if (hints.yKernel.MaxThreadsPerBlock >= 1024)
  hints.yBlockWidth = 32;
elseif (hints.yKernel.MaxThreadsPerBlock >= 256)
  hints.yBlockWidth = 16;
else
  hints.yBlockWidth = 8;
end
hints.yGridSize = ceil(hints.Q / hints.yBlockWidth);
hints.yKernel.ThreadBlockSize = [hints.yBlockWidth hints.yBlockWidth];
hints.yKernel.GridSize = hints.yGridSize;
hints.yKernel.SharedMemorySize = 2*(hints.yBlockWidth^2)*hints.valSize + hints.sizeHints;

% BG KERNEL
bgProto = [ ...
  'PRECISION * const,' ...
  'PRECISION * const,' ...
  'PRECISION * const,' ...
  'const PRECISION * const,' ...
  'const PRECISION * const, const PRECISION * const, const PRECISION * const, const PRECISION * const, PRECISION * const,' ...
  'const PRECISION * const, const PRECISION * const, const signed char * const,' ...
  'const long long, const long long, const long long,' ...
  'const long long * const, const long long, const PRECISION * const, const long long,' ...
  'const long long'];
bgProto = strrep(bgProto,'PRECISION',cPrecision);
hints.bgKernel = nnGPU.getKernel(['bg_' hints.precision],bgProto);

if (hints.bgKernel.MaxThreadsPerBlock >= 1024)
  hints.bgBlockWidth = 32;
elseif (hints.bgKernel.MaxThreadsPerBlock >= 256)
  hints.bgBlockWidth = 16;
else
  hints.bgBlockWidth = 8;
end
hints.bgGridSize = ceil(hints.Q / hints.bgBlockWidth);
hints.bgKernel.ThreadBlockSize = [hints.bgBlockWidth hints.bgBlockWidth];
hints.bgKernel.GridSize = hints.bgGridSize;
hints.bgKernel.SharedMemorySize = 2*(hints.bgBlockWidth^2)*hints.valSize + hints.sizeHints;

% ALLOCATE BG OUPUTS
hints.dWB = gpuArray(zeros(hints.gpuLearnWB.wbLen,hints.perfsGridSize,hints.precision));

% ALLOCATE TEMPORARY BG STORAGE
N_size = hints.QAligned * sum(hints.layer_sizes) * hints.TS;
dAc_size = hints.QAligned * sum(hints.layer_sizes) * (hints.numLayerDelays + hints.TS);
TEMP_size = N_size + dAc_size;
hints.TEMP = gpuArray(zeros(1,TEMP_size,hints.precision));
