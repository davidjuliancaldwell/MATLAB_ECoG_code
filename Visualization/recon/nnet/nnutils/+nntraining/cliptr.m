function tr=cliptr(tr,epochs)
%CLIPTR Clip training record to the final number of epochs.
%
%  Syntax
%
%    tr = nntraining.cliptr(tr,epochs)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of Neural Network Toolbox. We recommend
%    you do not write code which calls this function.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.8.3 $

indices = 1:(epochs+1);
names = fieldnames(tr);
for i=1:length(names)
  name = names{i};
  value = tr.(name);
  if isnumeric(value) && (numel(value) > epochs)
    tr.(name) = value(:,indices);
  end
end
