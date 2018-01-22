function wb = getwb(net,hints)
%GETWB Get all network weight and bias values as a single vector.
%
%  <a href="matlab:doc getwb">getwb</a>(NET) returns network NET's biases and weights as a single vector.
%
%  Here a feed forward network is trained to fit some data, then its
%  bias and weight values formed into a vector.
%  
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    wb = <a href="matlab:doc getwb">getwb</a>(net)
%
%  See also SETWB, FORMWB, SEPARATEWB.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.10.5 $ $Date: 2012/03/27 18:13:58 $

if nargin < 2, hints = nn.wb_indices(net); end

wb = formwb(net,net.b,net.IW,net.LW,hints);
