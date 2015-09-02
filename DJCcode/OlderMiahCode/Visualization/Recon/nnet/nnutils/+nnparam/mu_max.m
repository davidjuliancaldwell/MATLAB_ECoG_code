%Maximum mu (mu_max) function parameter
%
%  <a href="matlab:doc nnparam.mu_max">mu_max</a> is a <a href="matlab:doc nntrain">training function</a> parameter.
%  It must be a strictly positive scalar.
%
%  <a href="matlab:doc nnparam.mu_max">mu_max</a> is the maximum mu before training with the Levenberg-
%  Marquardt training function is stopped.
%
%  When mu gets too large, Levenberg-Marquardt training step sizes become
%  so small that training is no longer effective at improving performance.
%
%  These parameters are all related: <a href="matlab:doc nnparam.mu">mu</a>, <a href="matlab:doc nnparam.mu_dec">mu_dec</a>,
%  <a href="matlab:doc nnparam.mu_inc">mu_inc</a> and <a href="matlab:doc nnparam.mu_max">mu_max</a>.
%
%  This parameter is used by <a href="matlab:doc trainbr">trainbr</a> and <a href="matlab:doc trainlm">trainlm</a>.
 
