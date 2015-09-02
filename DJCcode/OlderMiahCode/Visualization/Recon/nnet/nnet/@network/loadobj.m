function net = loadobj(obj)
%LOADOBJ Load a network object.
%
%  <a href="matlab:doc loadobj">loadobj</a>(NET) is automatically called with a structure when
%  a network is loaded from a MAT file.  If the network is from a
%  previous version of Neural Network Toolbox software then
%  it is updated to the latest version.

% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.4.4.4 $ $Date: 2012/03/27 18:08:08 $

if isa(obj,'network')
  net = obj;
else
  net = nnupdate.net(obj);
  net = network(net);
end
