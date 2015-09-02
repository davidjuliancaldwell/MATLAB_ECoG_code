function lr = maxlinlr(p,b)
%MAXLINLR Maximum learning rate for a linear layer.
%
%  <a href="matlab:doc maxlinlr">maxlinlr</a> is used to calculate learning rates for NEWLIN.
%  
%  <a href="matlab:doc maxlinlr">maxlinlr</a>(X) takes an RxQ matrix of Q R-element input vectors and
%  returns the maximum learning rate for a linear layer without a bias
%  for stable learning on inputs X.
%
%  <a href="matlab:doc maxlinlr">maxlinlr</a>(X,'bias') returns the maximum learning rate for
%  a linear layer with a bias.
%  
%  Here we define a batch of 4 2-element input vectors and
%  find the maximum learning rate for a linear layer with
%  a bias.
%
%    X = [1 2 -4 7; 0.1 3 10 6];
%    lr = <a href="matlab:doc maxlinlr">maxlinlr</a>(X,'bias')
%  
%  See also LEARNWH.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $  $Date: 2011/02/28 01:27:08 $

if nargin < 1, error(message('nnet:Args:NotEnough')); end

if nargin == 1
  lr = 0.9999/max(eig(p*p'));
else
  p2=[p; ones(1,size(p,2))];
  lr = 0.9999/max(eig(p2*p2'));
end
