function net = sp2narx(net)
%SP2NARX Convert a series-parallel NARX network to parallel (feedback) form.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    net = sp2narx(NET)
%
%  Description
%
%    SP2NARX(NET) takes,
%      NET - Original NARX network in series-parallel form
%    and returns an NARX network in parallel (feedback) form.
%
%  Examples
%
%    Here a series-parallel narx network is created and converted from
%    series parallel to parallel narx.
%
%      P = {[0] [1] [1] [0] [-1] [-1] [0] [1] [1] [0] [-1]};
%      T = {[0] [1] [2] [2]  [1]  [0] [1] [2] [1] [0]  [1]};
%      net = newnarxsp(P,T,[1 2],[1 2],5);
%      net2 = sp2narx(net);
%
%  See also NEWNARXSP, NEWNARX

% Orlando De Jesús, Martin Hagan, 7-20-05
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.8.4 $

if nargin < 1, error(message('nnet:Args:NotEnough')), end

net = closeloop(net);
