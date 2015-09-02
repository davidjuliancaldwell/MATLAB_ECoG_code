function linkout = trainbr_performfcn_sse
%Training function TRAINBR requires performance function MSE or SSE.
%
%  Bayesian regularization assumes a performance function of <a href="matlab:doc mse">mse</a> or <a href="matlab:doc sse">sse</a>.
%
%  If a network's performance function is not one of those, then <a href="matlab:doc trainbr">trainbr</a>
%  will set it to <a href="matlab:doc mse">mse</a>.
%
%    net.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a> = 'mse'.
%
%  See also TRAINBR, MSE, SSE

% Copyright 2010 The MathWorks, Inc.

link = nnlink.warning_link('NET.performFcn has been set to MSE.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
