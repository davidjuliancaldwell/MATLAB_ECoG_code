function linkout = nnwarn_adaptive_reg_override
%Training functions that optimize regularization override static regularization.
%
%  Training functions that use adaptive regularization to optimize
%  generalization will turn off performance function regularization.
%  Bayesian regularization (<a href="matlab:doc trainbr">trainbr</a>) is one such algorithm.
%
%  I.e. if NET.<a href="matlab:doc nnproperty.net_performParam">performParam</a>.<a href="matlab:doc nnparam.regularization">regularization</a> is not zero, it will be set to 0.
%
%    net.<a href="matlab:doc nnproperty.net_performParam">performParam</a>.<a href="matlab:doc nnparam.regularization">regularization</a> = 0.
%
%  The training function is then able to update the network
%  according to performance.
%
%  If you wish to train with static performance regularization, use a
%  different training function such as Levenberg-Marquardt (<a href="matlab:doc trainlm">trainlm</a>).
%  
%  See also TRAINBR, TRAINLM

% Copyright 2010 The MathWorks, Inc.

link = nnlink.warning_link('NET.performParam.regularization has been set to 0.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
