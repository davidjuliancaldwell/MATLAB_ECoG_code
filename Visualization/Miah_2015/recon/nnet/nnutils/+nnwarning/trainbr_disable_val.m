function linkout = trainbr_disable_val
%The training function TRAINBR disables validation.
%
%  TRAINBR does not support validation and therefore reassigns
%  validation data to training data.
%
%  TRAINBR performs Levenberg-Marquardt optimization with adaptive
%  Bayesian regularization.  The regularization minimizes an adaptive
%  linear combination of mean squared errors (or equivalently,
%  sum squared errors) and squared  weights and biases.
%
%  Training is stopped when regularization yields a result deemed
%  likely to generalize well.  Validation stops would interfere with
%  this process.

% Copyright 2010 The MathWorks, Inc.

link = nnlink.warning_link('Validation data has been reassigned as training data.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
