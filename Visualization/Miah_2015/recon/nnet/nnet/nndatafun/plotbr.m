function flag_stop = plotbr(tr,name,epoch)
%PLOTBR Plot network performance for Bayesian regularization training.
%
%  <a href="matlab:doc plotbr">plotbr</a>(TR,NAME,EPOCH) takes a training record TR returned by <a href="matlab:doc train">train</a>,
%  and optionally the name of a training function NAME, and number of
%  epochs EPOCH, and plots the training sum squared error, the sum squared
%  weights and the effective number of parameters.
%
%  This plot is commonly used with the Bayesian training function <a href="matlab:doc trainbr">trainbr</a>.
%
%  Here input values X and associated targets T are defined and used to
%  train a feedforward network, before plotting the Bayesian regularization
%  value for the training record.
%
%    x = [-1:.05:1];
%    t = sin(2*pi*p)+0.1*randn(size(p));
%    net = feedforwardnet(20,'<a href="matlab:doc trainbr">trainbr</a>')
%	   [net,tr] = <a href="matlab:doc train">train</a>(net,p,t);
%	   <a href="matlab:doc plotbr">plotbr</a>(tr)
%
%  See also TRAINBR.

% Orlando De Jesus, 11-11-98, user stopping, etc.
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2011/05/09 01:01:06 $

flag_stop = 0;

% Special case 1: 'stop' callback
if nargin < 2, name = ''; end
if nargin < 3, 
   % check if tr is a string for the stop condition.
   if ~ischar(tr)
      epoch = length(tr.epoch)-1; 
   end
end

% Changes introduced by Orlando De Jesus 11/11/98
fig2 = 0;
z = get(0,'children');
for i=1:length(z)
  typ = get(z(i),'type');
  if strcmp(typ,'figure')
    nam = get(z(i),'tag');
    if strcmp(nam,'train')
  	  fig2 = z(i);
	    break
	  end
  end
end
if length(get(fig2,'children')) == 0, fig2 = 0; end

% Get name from SIMULINK block if available
if (length(ver('simulink')) > 0) && (gcbh ~= -1)
  theName = get_param(gcbh,'Name');
else
  theName = name;
end

newplot = 0;
if fig2==0
  newplot = 1;
   fig2 = figure('Units',          'pixel',...
                 'Name',           theName,...
                 'Tag',            'train',...
                 'NumberTitle',    'off',...
                 'IntegerHandle',  'off',...
                 'Toolbar',        'none');
end

if ischar(tr)
  if strcmp(tr,'stop') & (fig2)
     ud=get(fig2,'UserData');
     ud.stop=1;
     set(fig2,'UserData',ud);
     return
  end
end


if (epoch==0) | newplot
   z = get(fig2,'children');
   for i=1:length(z)
      delete (z(i));
   end
   figure(fig2);
   ud.TrainAxes1    = axes('Parent',fig2,'position',[0.13 0.70 0.77 0.22]);
   ud.TrainLine1    = plot(0,0,0,0,0,0,'EraseMode','None','Parent',ud.TrainAxes1);
   ud.TrainXlabel1  = xlabel('X Axis','Parent',ud.TrainAxes1);
   set(ud.TrainXlabel1,'string',' ');
   ud.TrainYlabel1  = ylabel('Y Axis','Parent',ud.TrainAxes1);
   ud.TrainTitle1   = get(ud.TrainAxes1,'Title');
   set(ud.TrainAxes1,'yscale','log');
   ud.TrainAxes2    = axes('Parent',fig2,'position',[0.13 0.40 0.77 0.22]);
   ud.TrainLine2    = plot(0,0,'EraseMode','None','Parent',ud.TrainAxes2);
   ud.TrainXlabel2  = xlabel('X Axis','Parent',ud.TrainAxes2);
   set(ud.TrainXlabel2,'string',' ');
   ud.TrainYlabel2  = ylabel('Y Axis','Parent',ud.TrainAxes2);
   ud.TrainTitle2   = get(ud.TrainAxes2,'Title');
   set(ud.TrainAxes2,'yscale','log');
   ud.TrainAxes3    = axes('Parent',fig2,'position',[0.13 0.10 0.77 0.22]);
   ud.TrainLine3    = plot(0,0,'EraseMode','None','Parent',ud.TrainAxes3);
   ud.TrainXlabel3  = xlabel('X Axis','Parent',ud.TrainAxes3);
   ud.TrainYlabel3  = ylabel('Y Axis','Parent',ud.TrainAxes3);
   ud.TrainTitle3   = get(ud.TrainAxes3,'Title');
   ud.XData      = [];
   ud.YData      = [];
   ud.Y2Data     = [];
   ud.stop_but = uicontrol('Parent',fig2, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','plotbr(''stop'',''PLOTBR'');', ...
	'ListboxTop',0, ...
	'Position',[2 2 68.75 15], ...
	'String','Stop Training', ...
   'Tag','Pushbutton1');
   ud.stop=0;
   set(fig2,'UserData',ud);
else
   ud=get(fig2,'UserData');
end

ind = 1:(epoch+1);
doTest = ~isnan(tr.tperf(1));
doValidation = ~isnan(tr.vperf(1));

set(ud.TrainLine3,...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.gamk(ind),...
      'linewidth',2,'color','b');

set(ud.TrainYlabel3,'string','# Parameters');
if epoch~=0
   % ODJ 9/27/01 Changes to avoid error when min_gamk == max_gamk
   min_gamk=min(tr.gamk(ind));
   max_gamk=max(tr.gamk(ind));
   if min_gamk == max_gamk
      set(ud.TrainAxes3,'xlim',[0 epoch],'ylim',[min(tr.gamk(ind))-1 max(tr.gamk(ind))+1]);
   else
      set(ud.TrainAxes3,'xlim',[0 epoch],'ylim',[min(tr.gamk(ind)) max(tr.gamk(ind))]);
   end
end

if doTest
  set(ud.TrainLine1(2),...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.tperf(ind),...
      'linewidth',2,'color','r');
end
if doValidation
  set(ud.TrainLine1(3),...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.vperf(ind),...
      'linewidth',2,'color','g');
end
set(ud.TrainLine1(1),...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.perf(ind),...
      'linewidth',2,'color','b');

ystring = 'Tr-Blue';
if (doValidation)
  ystring = [ystring '  Val-Green'];
end
if (doTest)
  ystring = [ystring '  Tst-Red'];
end

set(ud.TrainYlabel1,'string',ystring);
set(ud.TrainAxes1,'xticklabel',[]);

if epoch~=0
   % ODJ 9/27/01 Change to avoir error when min_trperf or max_trperf are NaN
   min_trperf = min([tr.perf(ind) tr.tperf(ind) tr.vperf(ind)]);
   max_trperf = max([tr.perf(ind) tr.tperf(ind) tr.vperf(ind)]);
   if ~isnan(min_trperf) & ~isnan(max_trperf)
      set(ud.TrainAxes1,'xlim',[0 epoch],'ylim',[10^fix(log10(min_trperf)-1) 10^ceil(log10(max_trperf))]);
   end
end

set(ud.TrainLine2,...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.ssX(ind),...
      'linewidth',2,'color','b');

set(ud.TrainYlabel2,'string','SSW');
set(ud.TrainAxes2,'xticklabel',[]);

if epoch~=0
  set(ud.TrainAxes2,'xlim',[0 epoch],'ylim',[10^fix(log10(min(tr.ssX(ind)))-1) 10^ceil(log10(max(tr.ssX(ind))))]);
end


tstring = sprintf('Training SSE = %g',tr.perf(epoch+1));
if (doTest)
  tstring = [tstring sprintf('    Test SSE = %g',tr.tperf(epoch+1));];
end
if (doValidation)
  tstring = [tstring sprintf('    Validation SSE = %g',tr.vperf(epoch+1));];
end
set(ud.TrainTitle1,'string',tstring);

tstring = sprintf('Squared Weights = %g',tr.ssX(epoch+1));
set(ud.TrainTitle2,'string',tstring);

tstring = sprintf('Effective Number of Parameters = %g',tr.gamk(epoch+1));
set(ud.TrainTitle3,'string',tstring);

if epoch == 0
   set(ud.TrainXlabel3,'string','Zero Epochs');
elseif epoch == 1
   set(ud.TrainXlabel3,'string','One Epoch');
else
   set(ud.TrainXlabel3,'string',[num2str(epoch) ' Epochs']);
end


if length(name)
  set(fig2,'name',['Training with ' name],'numbertitle','off')
end
if epoch > 0
   %  set(gca,'xlim',[0 epoch])
else
   figure(fig2);
end
drawnow

if ud.stop
   flag_stop = 1;
end

