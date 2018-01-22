%Regularization Ratio (regularization) function parameter
%
%  <a href="matlab:doc nnparam.regularization">regularization</a> is a <a href="matlab:doc nnperformance">performance function</a> parameter.
%  It must be a zero to one.
%
%  <a href="matlab:doc nnparam.regularization">regularization</a> is fraction of performance associated with
%  minimizing the weights and biases of a network.  If this is set to 0
%  then only error is minimized.  If it is set greater than zero then
%  weights and biases are also minimized which can result in a smoother
%  network function with better generalization.
%
%  Regularization is an alternative to using validation during training
%  to promote good generalization.
%
%  This parameter is used by <a href="matlab:doc mae">mae</a>, <a href="matlab:doc mse">mse</a>, <a href="matlab:doc sae">sae</a> and <a href="matlab:doc sse">sse</a>.
 
