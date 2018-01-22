function h = plotpc(w,b,hh)
%PLOTPC Plot a classification line on a perceptron vector plot.
%
%  <a href="matlab:doc plotpc">plotpc</a>(W,B) takes an SxR weight matrix (R must be 3 or less) and
%  an Sx1 bias vector, and returns a handle to a plotted perceptron
%  classification line.
%  
%  <a href="matlab:doc plotpc">plotpc</a>(W,B,H) takes the handle H from a previous call to this
%  function, and replaces the previous line with a new one.
%
%  This function does not change the current axis and is intended
%  to be called after <a href="matlab:doc plotpv">plotpv</a>.
%
%  For example, this code defines and plots the inputs and targets for a
%  perceptron:
%
%    x = [0 0 1 1; 0 1 0 1];
%    t = [0 0 0 1];
%    <a href="matlab:doc plotpv">plotpv</a>(x,t)
%
%  The following code creates a perceptron with inputs ranging
%  over the values in P, assigns values to its weights
%  and biases, and plots the resulting classification line.
%
%    net = <a href="matlab:doc perceptron">perceptron</a>;
%    net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{1}.<a href="matlab:doc nnproperty.input_size">size</a> = 2;
%    net.<a href="matlab:doc nnproperty.net_layers">layers</a>{1}.<a href="matlab:doc nnproperty.layer_size">size</a> = 1;
%    net.<a href="matlab:doc nnproperty.net_IW">IW</a>{1,1} = [-1.2 -0.5];
%    net.<a href="matlab:doc nnproperty.net_b">b</a>{1} = 1;
%    <a href="matlab:doc plotpc">plotpc</a>(net.<a href="matlab:doc nnproperty.net_IW">IW</a>{1,1},net.b{1})
%
%  See also PLOTPV.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.8.5 $  $Date: 2011/05/09 01:01:07 $

% ERROR CHECKING
% ==============

if nargin < 2, error(message('nnet:Args:NotEnough')), end

[wr,wc] = size(w);
[br,bc] = size(b);

if length(w) > 3,error(message('nnet:plotpc:WLarger33')),end
if br ~= wr, error(message('nnet:plotpc:WBRowMismatch')),end

% DEFAULTS
% ========

if max(wr,wc) <= 2
  plotdim = 2;
else
  plotdim = 3;
end

w = [w zeros(wr,3-wc)];
  
if nargin == 3
  delete(hh);
end

% PLOTTING
% ========

xlim = get(gca,'xlim');
ylim = get(gca,'ylim');
zlim = get(gca,'zlim');
view = get(gca,'view');

if nargout == 1, h = zeros(1,wr); end
co = 'mbrg';

hold on
for i = 1:wr
  c = [co(rem(i,4)+1) '-'];

  % 2-D PLOT

  if plotdim == 2
    if w(i,2) ~= 0
      x = xlim;
      y = (-w(i,1)*x-b(i))/w(i,2);
  elseif w(i,1) ~= 0
      y = ylim;
      x = (-w(i,2)*y-b(i))/w(i,1);
  else
    x = NaN;
    y = NaN;
  end
    hh = plot(x,y,c);
  
  % 3-D PLOT
  
  else
    x = [0:0.05:1]*(xlim(2)-xlim(1))+xlim(1);
    y = [0:0.05:1]*(ylim(2)-ylim(1))+ylim(1);
    [X,Y] = meshgrid(x,y);
    Z = -(X*w(i,1)+Y*w(i,2)+b(i)) / w(i,3);
    ind = find(Z < zlim(1) | Z > zlim(2));
    Z(ind) = NaN+Z(ind);
    hh = surf(x,y,Z);
  set(hh,'edgecolor',[1 1 1]*0.5)
  end

  if nargout == 1
    h(i) = hh;
  end
end
set(gca,'xlim',xlim);
set(gca,'ylim',ylim);
set(gca,'zlim',zlim);
set(gca,'view',view);
hold off
