% Neural network adaptFcn property.
% 
% NET.<a href="matlab:doc nnproperty.net_adaptFcn">adaptFcn</a>
%
% This property defines the <a href="matlab:doc nnadapt">adapt function</a> to update the network 
% during adaptive simulation with the function <a href="matlab:doc adapt">adapt</a>.
%
%   [net,Y,E,Pf,Af] = <a href="matlab:doc adapt">adapt</a>(NET,X,T,Pi,Ai,EW)
%
% Side Effects:
%
% Whenever this property is altered, the network's adaption parameters
% (net.<a href="matlab:doc nnproperty.net_adaptParam">adaptParam</a>) are set to contain the parameters and default values
% of the new function.

% Copyright 2010 The MathWorks, Inc.
