%Diameter root (root) function parameter
%
%  <a href="matlab:doc nnparam.root">root</a> is a <a href="matlab:doc nnplot">plot function</a> parameter.
%  It must be a positive integer.
%
%  <a href="matlab:doc nnparam.root">root</a> defines the root used to determine the diameter of
%  squares representing weights.  If it is two, then the are of each
%  square is proportional to the weight, if it is larger then differences
%  of larger weights are not so obvious, but differences in smaller
%  weights are enhanced.
%
%    diameter = abs(weight / max_weight) ^ (1/<a href="matlab:doc nnparam.root">root</a>);
%
%  This parameter is used by <a href="matlab:doc plotwb">plotwb</a>.
 
