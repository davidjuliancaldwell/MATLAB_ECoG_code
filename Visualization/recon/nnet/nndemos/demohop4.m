%% Hopfield Spurious Stable Points
% A Hopfield network with five neurons is designed to have four stable
% equilibria.  However, unavoidably, it has other undesired equilibria.
% 
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.18.2.3 $  $Date: 2010/03/22 03:58:54 $

%%
% We would like to obtain a Hopfield network that has the four stable points
% defined by the two target (column) vectors in T.

T = [+1 +1 -1 +1; ...
      -1 +1 +1 -1; ... 
      -1 -1 -1 +1; ...
      +1 +1 +1 +1; ...
      -1 -1 +1 +1];

%%
% The function NEWHOP creates Hopfield networks given the stable points T.

net = newhop(T);

%%
% Here we define 4 random starting points and simulate the Hopfield network for
% 50 steps.
%
% Some initial conditions will lead to desired stable points.  Others will lead
% to undesired stable points.

P = {rands(5,4)};
[Y,Pf,Af] = net({4 50},{},P);
Y{end}


displayEndOfDemoMessage(mfilename)
