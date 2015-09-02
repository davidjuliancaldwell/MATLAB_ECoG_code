function net=setwb(net,wb,hints)
%SETWB Set all network weight and bias values with a single vector.
%
%  <a href="matlab:doc setwb">setwb</a>(NET,WB) returns a network NET after setting its bias and
%  weight values from a single vector of values.
%
%  Here a feed forward network is configured for some data, then its
%  bias and weight values replaced with zeros.
%  
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc configure">configure</a>(net,x,t);
%    net = <a href="matlab:doc setwb">setwb</a>(net,zeros(1,net.numWeightElements));
%
%  See also GETWB, FORMWB, SEPARATEWB.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2012/03/27 18:14:01 $

if nargin < 3, hints = nn.wb_indices(net); end

[b,IW,LW] = separatewb(net,wb,hints);
net.b = b;
net.IW = IW;
net.LW = LW;
