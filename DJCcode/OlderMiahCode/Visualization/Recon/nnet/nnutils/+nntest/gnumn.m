function [grad,err,finaldelta] = gnumn(fun,x0)
%GNUMN Numerical gradient

% Estimate of the gradient vector of an analytical function of n variables
% usage: [grad,err,finaldelta] = nntest.gnumn(fun,x0)
%
% Uses nntest.dnumn to provide both derivative estimates
% and error estimates. fun needs not be vectorized.
% 
% arguments: (input)
%  fun - analytical function to differentiate. fun must
%        be a function of the vector or array x0.
% 
%  x0  - vector location at which to differentiate fun
%        If x0 is an nxm array, then fun is assumed to be
%        a function of n*m variables. 
%
% arguments: (output)
%  grad - vector of first partial derivatives of fun.
%        grad will be a row vector of length numel(x0).
%
%  err - vector of error estimates corresponding to
%        each partial derivative in grad.
%
%  finaldelta - vector of final step sizes chosen for
%        each partial derivative.
%
%
% Example:
%  [grad,err] = nntest.gnumn(@(x) sum(x.^2),[1 2 3])
%  grad =
%      2     4     6
%  err =
%      5.8899e-15    1.178e-14            0
%
%
% Example:
%  At [x,y] = [1,1], compute the numerical gradient
%  of the function sin(x-y) + y*exp(x)
%
%  z = @(xy) sin(diff(xy)) + xy(2)*exp(xy(1))
%
%  [grad,err ] = nntest.gnumn(z,[1 1])
%  grad =
%       1.7183       3.7183
%  err =
%    7.537e-14   1.1846e-13
%
%
% Example:
%  At the global minimizer (1,1) of the Rosenbrock function,
%  compute the gradient. It should be essentially zero.
%
%  rosen = @(x) (1-x(1)).^2 + 105*(x(2)-x(1).^2).^2;
%  [g,err] = nntest.gnumn(rosen,[1 1])
%  g =
%    1.0843e-20            0
%  err =
%    1.9075e-18            0
%
%
% See also: nntest.dnumn, gradient
%
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 2/9/2007

% Copyright 2007-2010 John D'Errico
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.


% get the size of x0 so we can reshape
% later.
sx = size(x0);

% total number of derivatives we will need to take
nx = numel(x0);

grad = zeros(1,nx);
err = grad;
finaldelta = grad;
for ind = 1:nx
  [grad(ind),err(ind),finaldelta(ind)] = nntest.dnumn( ...
    @(xi) fun(swapelement(x0,ind,xi)), ...
    x0(ind),'deriv',1,'vectorized','no', ...
    'methodorder',2);
end

end % mainline function end

% =======================================
%      sub-functions
% =======================================
function vec = swapelement(vec,ind,val)
% swaps val as element ind, into the vector vec
vec(ind) = val;

end % sub-function end


