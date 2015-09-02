function linkout = empty_performfcn_corrected
%Some training functions replace a missing performance function with MSE
%
%  Training functions that require a performance function to operate
%  correctly, will set NET.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a> to MSE (Mean Squared Error), if
%  its original value was the empty string ''.
%
%    net.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a> = 'mse'.
%
%  The training function is then able to update the network
%  according to performance.
%
%  If you wish to train a network with a different performance function,
%  then set it accordingly before calling the training function.
%  
%  See also MSE

% Copyright 2010 The MathWorks, Inc.

link = nnlink.warning_link('NET.performFcn has been set to MSE.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
