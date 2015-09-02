%Window Size (window) function parameter
%
%  <a href="matlab:doc nnparam.window">window</a> is a <a href="matlab:doc nnlearn">learning function</a> parameter.
%  It must be a positive scalar.
%
%  <a href="matlab:doc nnparam.window">window</a> is limit defining when learning occurs. If the
%  distances of the closes neuron's weights from the input vector d1,
%  and the second closest neuron's weights d2, meet this relationship
%  the <a href="matlab:doc learnlv2">learnlv2</a> adjusts the weights, otherwise it does not.
%
%     d1/d2 > (1-window)/(1+window).
%
%  This parameter is used by <a href="matlab:doc learnlv2">learnlv2</a>.
 
