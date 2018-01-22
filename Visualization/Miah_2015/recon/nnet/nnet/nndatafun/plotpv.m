function plotpv(p,t,v)
%PLOTPV Plot perceptron input/target vectors.
%
%  <a href="matlab:doc plotpv">plotpv</a>(X,T) take an RxQ matrix of Q R-element input vectors X and
%  an SxQ matrix of S-element target vectors T, and plots the columns of
%  X with markers based on T.
%  
%  <a href="matlab:doc plotpv">plotpv</a>(P,T,V) takes an additional input V defining the graph limits
%  as four elements of a row vector [x_min x_max y_min y_max].
%
%  This code defines and plots the inputs and targets for a perceptron:
%
%    x = [0 0 1 1; 0 1 0 1];
%    t = [0 0 0 1];
%    <a href="matlab:doc plotpv">plotpv</a>(x,t)
%
%  This code creates a perceptron with inputs ranging
%  over the values in P, assigns values to its weights
%  and biases, and plots the resulting classification line.
%
%    net = <a href="matlab:doc perceptron">perceptron</a>;
%    net.<a href="matlab:doc nnproperty.net_layers">layers</a>{1}.<a href="matlab:doc nnproperty.layer_size">size</a> = 1;
%    net.<a href="matlab:doc nnproperty.net_IW">IW</a>{1,1} = [-1.2 -0.5];
%    net.<a href="matlab:doc nnproperty.net_b">b</a>{1} = 1;
%    <a href="matlab:doc plotpc">plotpc</a>(net.<a href="matlab:doc nnproperty.net_IW">IW</a>{1,1},net.b{1})
%
%  See also PLOTPC.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $  $Date: 2011/02/28 01:27:24 $

% ERROR CHECKING
% ==============

if nargin < 2, error(message('nnet:Args:NotEnough')),end

[pr,pc] = size(p);
[tr,tc] = size(t);

if (pr > 3), error(message('nnet:plotpv:PNot123Rows')), end
if tr > 3, error(message('nnet:plotpv:TNot123Rows')), end

% DEFAULTS
% ========

if max(pr,tr) <= 2
  plotdim = 2;
else
  plotdim = 3;
end

p = [p; zeros(3-pr,pc)];
t = [t; zeros(3-tr,tc)];

if nargin == 2
  minx = min(p(1,:));
  maxx = max(p(1,:));
  miny = min(p(2,:));
  maxy = max(p(2,:));
  edgx = (maxx-minx)*0.4+0.1;
  edgy = (maxy-miny)*0.4+0.1;
  minz = min(p(3,:));
  maxz = max(p(3,:));
  edgz = (maxz-minz)*0.4;
  if plotdim == 2
    v = [minx-edgx maxx+edgx miny-edgy maxy+edgy];
  else
    v = [minx-edgx maxx+edgx  miny-edgy maxy+edgy minz-edgz maxz+edgz];
  end
end

% MARKERS
% =======

marker = ['ob';'or';'*b';'*r';'+b';'+r';'xb';'xr'];

% PLOTTING
% ========

for i=1:pc
  m = marker([4 2 1]*t(:,i)+1,:);
  plot3(p(1,i),p(2,i),p(3,i),m)
  hold on
end

% PLOT SET UP
% ===========

set(gca,'box','on')
title('Vectors to be Classified')
xlabel('P(1)');
ylabel('P(2)');

if plotdim <= 2
  view(2)
else
  view(3)
  zlabel('P(3)')
end
axis(v)
hold off

