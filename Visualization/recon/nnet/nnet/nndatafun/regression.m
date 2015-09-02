function [r,m,b] = regression(targets,outputs,flag)
%REGRESSION Linear regression.
%  
%  <a href="matlab:doc regression">regression</a> calculates the linear regression between each element
%   of the network response and the corresponding target.
%  
%  [R,M,B] = <a href="matlab:doc regression">regression</a>(T,Y) takes cell array or matrix targets T and
%  output Y, each with total matrix rows of N, and returns the linear
%  regression for each of the N rows: the regression values R, slopes M,
%  and y-intercepts B.
%
%  <a href="matlab:doc regression">regression</a>(T,Y,'one') returns scalar R, M and B values across all
%  rows of targets and outputs.
%
%  Here a feedforward network is trained and regression performed on its
%  targets and outputs.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x);
%    [r,m,b] = <a href="matlab:doc regression">regression</a>(t,y)
%
%  See also PLOTREGRESSION

% Copyright 2010 The MathWorks, Inc.

if nargin < 2, error(message('nnet:Args:NotEnough')); end

if iscell(targets), targets = cell2mat(targets); end
if iscell(outputs), outputs = cell2mat(outputs); end

if all(size(targets) ~= size(outputs))
  error(message('nnet:NNData:TYMismatch'))
end

if (nargin >= 3) && ischar(flag) && strcmp(flag,'one')
  targets = targets(:)';
  outputs = outputs(:)';
end

[N,Q] = size(targets);
m = zeros(N,1);
b = zeros(N,1);
r = zeros(N,1);
for i=1:N
  t = targets(i,:);
  y = outputs(i,:);
  ignore = find(isnan(t) | isnan(y));
  t(ignore) = [];
  y(ignore) = [];
  Quse = Q - length(ignore);
  h = [t' ones(size(t'))];
  yt = y';
  theta = h\yt;
  m(i) = theta(1);
  b(i) = theta(2);
  yn = y - mean(y);
  tn = t - mean(t);
  sty = std(yn);
  stt = std(tn);
  r(i) = yn*tn'/(Quse - 1);
  if (sty~=0)&&(stt~=0)
    r(i) = r(i)/(sty*stt);
  end
end
