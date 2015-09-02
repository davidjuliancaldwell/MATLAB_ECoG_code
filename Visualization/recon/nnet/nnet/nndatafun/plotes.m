function plotes(wv,bv,es,v)
%PLOTES Plot the error surface of a single input neuron.
%
%  <a href="matlab:doc plotes">plotes</a>(WV,BV,ES,V) takes a 1xN vector of weight values WV, a 1xM
%  vector of bias values BV, an MxN matrix defining the error surface ES,
%  and a 2-element vector V defining the view, with default [-37.5, 30].
%
%  The error surface ES can be calculated with <a href="matlab:doc errsurf">errsurf</a>.
%
%  Here is an example error surface plot.
%  
%    x = [3 2];
%    t = [0.4 0.8];
%    wv = -4:0.4:4; bv = wv;
%    es = <a href="matlab:doc errsurf">errsurf</a>(x,t,wv,bv,'logsig');
%    <a href="matlab:doc plotes">plotes</a>(wv,bv,es,[60 30])
%           
%  See also ERRSURF.

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $

if nargin < 3, error(message('nnet:Args:NotEnough')),end

maxe = max(max(es));
mine = min(min(es));
drop = maxe-mine;
surfpos = mine - drop;
contpos = mine - drop*0.95;

newplot;

% LEFT 3-D PLOT
% =============

subplot(1,2,1);
[px,py] = gradient(es,wv,bv);
scolor = sqrt(px.^2+py.^2);

% SURFACE
sh = surf(wv,bv,es,scolor);
hold on
sh = surf(wv,bv,zeros(length(wv),length(bv))+surfpos,scolor);
set(sh,'edgecolor',[0.5 0.5 0.5])

% ERROR GOAL
if false
minw = min(wv);
maxw = max(wv);
minb = min(bv);
maxb = max(bv);
z1 = plot3([minw maxw maxw minw minw],...
      [minb minb maxb maxb minb],[0 0 0 0 0],'w');
z2 = plot3([minw minw],[minb minb],[0 es(1,1)],'w');
z3 = plot3([maxw maxw],[minb minb],[0 es(1,length(wv))],'w');
z4 = plot3([maxw maxw],[maxb maxb],[0 es(length(bv),length(wv))],'w');
z5 = plot3([minw minw],[maxb maxb],[0 es(length(bv),1)],'w');
set([z1 z2 z3 z4 z5],'color',[1 1 0])
end

% TITLES
xlabel('Weight W');
ylabel('Bias B');
zlabel('Sum Squared Error')
title('Error Surface')

% WEIGHT & BIAS
set(gca,'xlim',[min(wv),max(wv)])
set(gca,'ylim',[min(bv),max(bv)])
%zlim = get(gca,'zlim');

% VIEW
if nargin == 4, view(v), end
set(gca,'zlim',[surfpos maxe]);

% RIGHT 2-D PLOT
% ==============

subplot(1,2,2);

% SURFACE
sh = surf(wv,bv,es*0,scolor);
hold on
set(sh,'edgecolor',[0.5 0.5 0.5])

% CONTOUR
contour(wv,bv,es,12);
hold off

% TITLES
xlabel('Weight W');
ylabel('Bias B');
title('Error Contour')

% VIEW
view([0 90])
set(gca,'xlim',[min(wv) max(wv)])
set(gca,'ylim',[min(bv) max(bv)])

% COLOR
colormap(cool);

