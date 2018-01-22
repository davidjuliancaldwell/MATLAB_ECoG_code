function hh = plotep(w,b,e,h)
%PLOTEP Plot a weight-bias position on an error surface.
%
%  <a href="matlab:doc plotep">plotep</a> is used to show network learning on a plot created by <a href="matlab:doc plotes">plotes</a>.
%  
%  <a href="matlab:doc plotep">plotep</a>(W,B,E) takes a weight value W, bias value B and error E and
%  returns a vector H containing information for continuing the plot.
%  
%  <a href="matlab:doc plotep">plotep</a>(W,B,E,H) continues plotting using the vector H,
%  returned by the last call to PLOTEP.
%  
%  H contains handles to dots plotted on the error surface,
%  so they can be deleted next time, as well as points on
%  the error contour, so they can be connected.
%  
%  See also ERRSURF, PLOTES.

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $  $Date: 2011/02/28 01:27:21 $

if nargin < 3, error(message('nnet:Args:NotEnough')),end

% GET LAST POSITION
% =================

if nargin == 4
  w2 = h(1);
  b2 = h(2);
  delete(h(3:length(h)));
end

% MOVE MARKERS
% ============
hold on
subplot(1,2,1);
zlim = get(gca,'zlim');
up = -zlim(1)*0.05;
plot3(w,b,zlim(1)+up,'.w')
h2 = plot3([w w],[b b],[e zlim(1)]+up,'.w','markersize',20);

subplot(1,2,2);
h1 = plot(w,b,'.w','markersize',20);

% CONNECT NEW POSITION
% ====================

if nargin == 4
  subplot(1,2,1)
  plot3([w2 w],[b2 b],[0 0]+zlim(1)+up,'b','linewidth',2)

  subplot(1,2,2)
  plot([w w2],[b b2],'b','linewidth',2);
end

hold off
drawnow

if nargout == 1
  hh = [w; b; h1; h2];
end

