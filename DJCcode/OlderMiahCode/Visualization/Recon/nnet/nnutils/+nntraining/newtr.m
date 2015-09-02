function tr=newtr(epochs,varargin)
%NEWTR New training record with any number of optional fields.
%
%  Syntax
%
%    tr = newtr(epochs,'fieldname1','fieldname2',...)
%    tr = newtr([firstEpoch epochs],'fieldname1','fieldname2',...)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of Neural Network Toolbox. We recommend
%    you do not write code which calls this function.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2011/05/09 01:05:09 $

if nargin < 1,error(message('nnet:Args:NotEnough')),end

names = varargin;
tr.epoch = 0:epochs;
blank = zeros(1,epochs+1)+NaN;
for i=1:length(names)
  eval(['tr.' names{i} '=blank;']);
end
