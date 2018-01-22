function dy = backprop(t,y,e,param)
%MSE.BACKPROP

% Copyright 2012 The MathWorks, Inc.

dy = -sign(e);
