function m = errsurf(p,t,wv,bv,f)
%ERRSURF Error surface of single input neuron.
%
%  <a href="matlab:doc errsurf">errsurf</a>(X,T,WV,BV,F) takes 1xQ inputs X, 1xQ targets T, a row
%  vector of weight values WV, row vector of bias values BV, and a transfer
%  function F.  It returns a matrix of error values over WV and BV. This
%  matrix defines an error surface.
%
%  Here is an example including a plot of the error surface.
%
%    x = [-6.0 -6.1 -4.1 -4.0 +4.0 +4.1 +6.0 +6.1];
%    t = [+0.0 +0.0 +.97 +.99 +.01 +.03 +1.0 +1.0];
%    wv = -1:.1:1;
%    bv = -2.5:.25:2.5;
%    es = <a href="matlab:doc errsurf">errsurf</a>(x,t,wv,bv,'logsig');
%    <a href="matlab:doc plotes">plotes</a>(wv,bv,es,[60 30])
%
%  See also PLOTES.

% Mark Beale, 1-31-92.
% Revised 12-15-93, MB
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $  $Date: 2011/02/28 01:26:57 $

if nargin < 5,error(message('nnet:Args:NotEnough'));end

m = zeros(length(bv),length(wv));
for Y=1:length(bv);
  m(Y,:) = sum((t'*ones(1,length(wv))-feval(f,p'*wv+bv(Y))).^2,1);
end
