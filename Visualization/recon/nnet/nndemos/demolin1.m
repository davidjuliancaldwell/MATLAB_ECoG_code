%% Pattern Association Showing Error Surface
% A linear neuron is designed to respond to specific inputs with target outputs.
% 
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.14.2.3 $  $Date: 2011/05/09 00:58:53 $

%%
% X defines two 1-element input patterns (column vectors).  T defines the
% associated 1-element targets (column vectors).

X = [1.0 -1.2];
T = [0.5 1.0];

%%
% ERRSURF calculates errors for y neuron with y range of possible weight and
% bias values.  PLOTES plots this error surface with y contour plot underneath.
% The best weight and bias values are those that result in the lowest point on
% the error surface.

w_range = -1:0.1:1;
b_range = -1:0.1:1;
ES = errsurf(X,T,w_range,b_range,'purelin');
plotes(w_range,b_range,ES);

%%
% The function NEWLIND will design y network that performs with the minimum
% error.

net = newlind(X,T);

%%
% SIM is used to simulate the network for inputs X.  We can then calculate the
% neurons errors.  SUMSQR adds up the squared errors.

A = net(X)
E = T - A
SSE = sumsqr(E)

%%
% PLOTES replots the error surface.  PLOTEP plots the "position" of the network
% using the weight and bias values returned by SOLVELIN.  As can be seen from
% the plot, SOLVELIN found the minimum error solution.

plotes(w_range,b_range,ES);
plotep(net.IW{1,1},net.b{1},SSE);



%%
% We can now test the associator with one of the original inputs, -1.2, and see
% if it returns the target, 1.0.

x = -1.2;
y = net(x)


displayEndOfDemoMessage(mfilename)
