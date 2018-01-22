function y = vec2ind(x)
%VEC2IND Transform vectors to indices.
%
%  <a href="matlab:doc ind2vec">ind2vec</a> and <a href="matlab:doc vec2ind">vec2ind</a> allow indices to be represented either directly
%  or as column vectors containing a 1 in the row of the index they
%  represent.
%
%  <a href="matlab:doc vec2ind">vec2ind</a>(V) takes an NxM matrix V and returns a 1xM vector of indices
%  indicating the position of the largest element in each column of V.
%
%  Here four vectors (containing only one 1 each) are defined and the
%  indices of the 1's are found.  The indices are then converted back to
%  the original vector representation.
%
%      vec = [1 0 0 0; 0 0 1 0; 0 1 0 1]
%      ind = <a href="matlab:doc vec2ind">vec2ind</a>(vec)
%      vec2 = <a href="matlab:doc ind2vec">ind2vec</a>(ind)
%  
%  See also IND2VEC.

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.3 $  $Date: 2011/02/28 01:27:42 $

if nargin < 1,error(message('nnet:Args:NotEnough'));end
wasMatrix = ~iscell(x);
x = nntype.data('format',x,'Argument');

y = cell(size(x));
for i=1:numel(x)
  [~,y{i}] = max(x{i},[],1);
end

if wasMatrix, y = y{1}; end

