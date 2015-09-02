function linkout = adaptive_regress_override
%Training functions that optimize regularization override performance regression.
%
%  Training functions that use adaptive regularization to optimize
%  generalization will turn off performance function regularization.
%  Bayesian regularization (<a href = 'matlab:doc trainbr>TRAINBR</a>) is one such algorithm.
%
%  I.e. if NET.<a href="matlab:doc nnproperty.net_performParam">performParam</a>.<a href="matlab:doc nnparam.regularization">regularization</a> is not zero, it will be set to 0.
%
%    net.<a href="matlab:doc nnproperty.net_performParam">performParam</a>.<a href="matlab:doc nnparam.regularization">regularization</a> = 0.
%
%  The training function is then able to update the network
%  according to performance.
%
%  If you wish to train with static performance regularization, use a
%  different training function such as Levenberg-Marquardt (TRAINLM).
%  
%  See also TRAINBR, TRAINLM

% Copyright 2010-2012 The MathWorks, Inc.

link = nnlink.warning_link('NET.performParam.regression has been set to 0.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
