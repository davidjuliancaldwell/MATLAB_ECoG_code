%Mu (mu) function parameter
%
%  <a href="matlab:doc nnparam.mu">mu</a> is a <a href="matlab:doc nntrain">training function</a> parameter.
%  It must be a strictly positive scalar.
%
%  <a href="matlab:doc nnparam.mu">mu</a> is the initial mu for training with the Levenberg-Marquardt
%  training function.
%
%  Mu is a blending factor. The greater it is the more weight is given to
%  gradient descent learning and a small step size.  The smaller it is the
%  more weight is given to large step sizes with Newton's method.
%
%  This parameter is used by <a href="matlab:doc trainbr">trainbr</a> and <a href="matlab:doc trainlm">trainlm</a>.
 
