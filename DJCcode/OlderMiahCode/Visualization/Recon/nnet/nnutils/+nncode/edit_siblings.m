function edit_siblings(mfunction)
%EDIT_SIBLINGS Edit sibling files of a modular function.

% Copyright 2010 The MathWorks, Inc.

mfunctions = nnfcn.siblings(mfunction);
edit(mfunctions{:});
