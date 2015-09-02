function h2 = plottr(tr,g,h)
%PLOTTR Plot error and learning rate over epochs.
%  
% Obsoleted in R2008b NNET 6.0.  Last used in R2007b NNET 5.1.
%
%  Use PLOTPERF to plot training records.

nnerr.obs_fcn('barerr','Use BAR to make bar plots.')

%  PLOTTR(TR,G)
%    TR - Matrix of two row vectors.
%    G  - Error goal.
%  Returns (optionally) handle to error curve in plot.
%  
%  PLOTTR(TR,G,H)
%    H - Handle returned by previous call to PLOTERR.
%  Deletes old error curve H, and plots new one.
%  
%  TR must have two rows.  This first row holds error
%  values, the second row holds learning rates.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.11.4.4 $  $Date: 2011/05/09 01:03:47 $

if nargin < 1,error(message('nnet:Args:NotEnough')), end

[plots,epochs] = size(tr);
epochs = epochs - 1;
t = sprintf('Training for %g Epochs',epochs);

% BACKWARD COMPATIBILITY FOR NNT 1.0
% Convert PLOTTR(E,T) -> PLOTTR(E)
nargin2  = nargin;
if nargin2 == 2
  if ischar(g)
    t = g;
  nargin2 = 1;
  end
end

if nargin2 < 3
  newplot;
  delete(get(gca,'children'))

  % ERROR PLOT
  subplot(plots,1,1)
  hold on
  if nargin2 == 2
    plot([0 999999],[g g],'r:',0,g*0.9,'.b')
  end
  xlabel('Epoch')
  ylabel('Sum-Squared Error')
  title(t)
  set(gca,'box','on')

  % LEARNING RATE PLOT
  if plots > 1
    subplot(2,1,2)
    hold on
    xlabel('Epoch')
    ylabel('Learning Rate')
    set(gca,'box','on')
  end
else
  delete(h);
end

% ERROR PLOT
subplot(plots,1,1)
hold on
H = plot(0:epochs,tr(1,:));
title(t)
hold off
set(gca,'xlim',[0 epochs+eps]);
set(gca,'ylim',[0 1]);
set(gca,'ylimmode','auto')
set(gca,'yscale','log');
hold off

% LEARNING RATE PLOT
if plots > 1
  subplot(2,1,2)
  hold on
  H = [H plot(0:epochs,tr(2,:))];
  hold off
end
drawnow

if nargout == 1
  h2 = H;
end
