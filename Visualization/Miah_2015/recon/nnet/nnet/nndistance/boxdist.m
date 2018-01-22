function d = boxdist(w,varargin)
%BOXDIST Box distance function.
%
% <a href="matlab:doc boxdist">boxdist</a>(P) takes an RxQ matrix P of Q R-element column vectors, and
% returns a QxQ matrix of the distances between each of the Q vectors.
%
% The box distance between two vectors P(:,i) and P(:,j) is
% calculated as D(i,j) = max(abs(P(:,i) - P(:,j))).
%
% For instance, here the distances between 12 neurons arranged in an
% 4x3 hexagonal grid are calculated.
%
%   positions = <a href="matlab:doc hextop">hextop</a>(4,3);
%   distances = <a href="matlab:doc boxdist">boxdist</a>(positions);
%
% Here is how to assign this function to define the distances in the same
% way between the neurons in layer i of a network. Then the neuron's
% positions and distances can be accessed:
%
%  net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_topologyFcn">topologyFcn</a> = '<a href="matlab:doc hextop">hextop</a>';
%  net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distanceFcn">distanceFcn</a> = '<a href="matlab:doc boxdist">boxdist</a>';
%  net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_positions">positions</a>
%  net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distances">distances</a>
%
% <a href="matlab:doc boxdist">boxdist</a>, like all distance functions, may be used as a weight function.
%
% Z = <a href="matlab:doc boxdist">boxdist</a>(W,P) takes an SxR weight matrix and RxQ input matrix and
% returns the SxQ matrix of distances between W's rows and P's columns.
% <a href="matlab:doc boxdist">boxdist</a>(P',P) returns the same result as <a href="matlab:doc boxdist">boxdist</a>(P).
%
% See <a href="matlab:doc dotprod">dotprod</a> for more information on how weight functions are used.
%
% See also DIST, MANDIST, LINKDIST, DOTPROD.

% Mark Beale, 11-31-97
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.12 $

% NNET 7.0 Backward Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(w)
  d = nnet7.weight_fcn(mfilename,w,varargin{:});
  return
end

% Distance
if (nargin < 2) || ~isnumeric(varargin{1})
  d = boxdist.distance(w,varargin{:});
else
  % Apply Weight
  d = boxdist.apply(w,varargin{:});
end
