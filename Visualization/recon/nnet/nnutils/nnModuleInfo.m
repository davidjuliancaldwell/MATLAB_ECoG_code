function info = nnModuleInfo(f)

% Copyright 2012 The MathWorks, Inc.

info.WARNING1 = 'THIS IS AN IMPLEMENTATION STRUCTURE';
info.WARNING2 = 'THIS INFORMATION MAY CHANGE WITHOUT NOTICE';
info.name = feval([f '.name']);
info.mfunction = f;
info.type = feval([f '.type']);
info.typeName = feval(['nntype.' info.type],'name');
info = feval(['nn_' info.type '.info'],info);
