function linkout = nonjacobian_performfcn_replaced
%Training functions using Jacobian calculations require MSE or SSE.
%
%  Training functions that use Jacobian calculations to operate
%  correctly, will set NET.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a> to MSE (Mean Squared Error), if
%  its originally value was not MSE or SSE.
%
%    net.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a> = 'mse'.
%
%  The training function is then able to update the network
%  according to performance.
%
%  If you wish to train with SSE instead, then set NET.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a>
%  accordingly before calling the training function.
%  
%  See also MSE, SSE, TRAINLM, TRAINBR

% Copyright 2010 The MathWorks, Inc.

link = nnlink.warning_link('NET.performFcn was not MSE or SSE, has been set to MSE.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
