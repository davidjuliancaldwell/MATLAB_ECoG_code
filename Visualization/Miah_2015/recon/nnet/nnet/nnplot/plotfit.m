function out1 = plotfit(varargin)
%PLOTFIT Plot function fit.
%
% <a href="matlab:doc plotfit">plotfit</a>(net,inputs,targets) plots a network's input-output function
% against the target data.
%
% <a href="matlab:doc plotfit">plotfit</a>(net,inputs1,targets1,name1,inputs2,targets2,name2,...) plots
% multiple sets of data.
%
% <a href="matlab:doc plotfit">plotfit</a>(...,'outputIndex',outputIndex) plots using an optional parameter
% overrides the default index of the output element being plotted (1).
%
% Here a feed-forward network is used to solve a simple fitting problem:
%
%   [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%   net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc plotfit">plotfit</a>(net,x,t)
%    
% See also plotregression, ploterrhist, plotresponse.

% Copyright 2007-2012 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Transfer Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if nargin == 0
    fig = nnplots.find_training_plot(mfilename);
    if nargout > 0
      out1 = fig;
    elseif ~isempty(fig)
      figure(fig);
    end
    return;
  end
  in1 = varargin{1};
  if ischar(in1)
    switch in1
      case 'info',
        out1 = INFO;
      case 'suitable'
        [args,param] = nnparam.extract_param(varargin,INFO.defaultParam);
        [net,tr,signals] = deal(args{2:end});
        update_args = standard_args(net,tr,signals);
        unsuitable = unsuitable_to_plot(param,update_args{:});
        if nargout > 0
          out1 = unsuitable;
        elseif ~isempty(unsuitable)
          for i=1:length(unsuitable)
            disp(unsuitable{i});
          end
        end
      case 'training_suitable'
        [net,tr,signals,param] = deal(varargin{2:end});
        update_args = training_args(net,tr,signals,param);
        unsuitable = unsuitable_to_plot(param,update_args{:});
        if nargout > 0
          out1 = unsuitable;
        elseif ~isempty(unsuitable)
          for i=1:length(unsuitable)
            disp(unsuitable{i});
          end
        end
      case 'training'
        [net,tr,signals,param] = deal(varargin{2:end});
        update_args = training_args(net,tr,signals);
        fig = nnplots.find_training_plot(mfilename);
        if isempty(fig)
          fig = figure('visible','off','tag',['TRAINING_' upper(mfilename)]);
          plotData = setup_figure(fig,INFO,true);
        else
          plotData = get(fig,'userdata');
        end
        set_busy(fig);
        unsuitable = unsuitable_to_plot(param,update_args{:});
        if isempty(unsuitable)
          set(0,'CurrentFigure',fig);
          plotData = update_plot(param,fig,plotData,update_args{:});
          update_training_title(fig,INFO,tr)
          nnplots.enable_plot(plotData);
        else
          nnplots.disable_plot(plotData,unsuitable);
        end
        fig = unset_busy(fig,plotData);
        if nargout > 0, out1 = fig; end
      case 'close_request'
        fig = nnplots.find_training_plot(mfilename);
        if ~isempty(fig),close_request(fig); end
      case 'check_param'
        out1 = ''; % TODO
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    [args,param] = nnparam.extract_param(varargin,INFO.defaultParam);
    update_args = standard_args(args{:});
    if ischar(update_args)
      nnerr.throw(update_args);
    end
    [plotData,fig] = setup_figure([],INFO,false);
    unsuitable = unsuitable_to_plot(param,update_args{:});
    if isempty(unsuitable)
      plotData = update_plot(param,fig,plotData,update_args{:});
      nnplots.enable_plot(plotData);
    else
      nnplots.disable_plot(plotData,unsuitable);
    end
    set(fig,'visible','on');
    drawnow;
    if nargout > 0, out1 = fig; end
  end
end

function set_busy(fig)
  set(fig,'userdata','BUSY');
end

function close_request(fig)
  ud = get(fig,'userdata');
  if ischar(ud)
    set(fig,'userdata','CLOSE');
  else
    delete(fig);
  end
  drawnow;
end

function fig = unset_busy(fig,plotData)
  ud = get(fig,'userdata');
  if ischar(ud) && strcmp(ud,'CLOSE')
    delete(fig);
    fig = [];
  else
    set(fig,'userdata',plotData);
  end
  drawnow;
end

function tag = new_tag
  tagnum = 1;
  while true
    tag = [upper(mfilename) num2str(tagnum)];
    fig = nnplots.find_plot(tag);
    if isempty(fig), return; end
    tagnum = tagnum+1;
  end
end

function [plotData,fig] = setup_figure(fig,info,isTraining)
  PTFS = nnplots.title_font_size;
  if isempty(fig)
    fig = get(0,'CurrentFigure');
    if isempty(fig) || strcmp(get(fig,'nextplot'),'new')
      if isTraining
        tag = ['TRAINING_' upper(mfilename)];
      else
        tag = new_tag;
      end
      fig = figure('visible','off','tag',tag);
      if isTraining
        set(fig,'CloseRequestFcn',[mfilename '(''close_request'')']);
      end
    else
      clf(fig);
      set(fig,'tag','');
      set(fig,'tag',new_tag);
    end
  end
  set(0,'CurrentFigure',fig);
  ws = warning('off','MATLAB:Figure:SetPosition');
  plotData = setup_plot(fig);
  warning(ws);
  if isTraining
    set(fig,'nextplot','new');
    update_training_title(fig,info,[]);
  else
    set(fig,'nextplot','replace');
    set(fig,'name',[info.name ' (' mfilename ')']);
  end
  set(fig,'NumberTitle','off','toolbar','none');
  plotData.CONTROL.text = uicontrol('parent',fig,'style','text',...
    'units','normalized','position',[0 0 1 1],'fontsize',PTFS,...
    'fontweight','bold','foreground',[0.7 0 0]);
  set(fig,'userdata',plotData);
end

function update_training_title(fig,info,tr)
  if isempty(tr)
    epochs = '0';
    stop = '';
  else
    epochs = num2str(tr.num_epochs);
    if isempty(tr.stop)
      stop = '';
    else
      stop = [', ' tr.stop];
    end
  end
  set(fig,'name',['Neural Network Training ' ...
    info.name ' (' mfilename '), Epoch ' epochs stop]);
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnPlot(mfilename,'Fit',7.0,[...
  nnetParamInfo('outputIndex','Output Index','nntype.pos_int_scalar',1,...
      'Index of output/target element to plot.'), ...
  ]);
end

function args = training_args(net,tr,data)
  x  = {data.X};
  t = {gmultiply(data.train.mask,data.T)};
  names = {'Training'};
  if ~isempty(data.val.indices)
    x = [x {data.X}];
    t = [t {gmultiply(data.val.mask,data.T)}];
    names = [names {'Validation'}];
  end
  if ~isempty(data.test.indices)
    x = [x {data.X}];
    t = [t {gmultiply(data.test.mask,data.T)}];
    names = [names {'Test'}];
  end
  args = {net x t names};
end

function args = standard_args(varargin)
  if nargin < 3
    args = 'Not enough input arguments.';
  elseif (nargin > 3) && (rem(nargin-1,3) ~= 0)
    args = 'Incorrect number of input arguments.';
  elseif nargin == 3
    % plotfit(net,x,t)
    net = varargin{1};
    x = { nntype.data('format',varargin{2}) };
    t = { nntype.data('format',varargin{3}) };
    names = {''};
    args = {net x t names};
  else
    % plotfit(net,x1,t1,name1,...)
    net = varargin{1};
    % TODO - Check data is consistent for network
    % TODO - Check data is consistent timesteps
    count = (nargin-1)/3;
    x = cell(1,count);
    t = cell(1,count);
    names = cell(1,count);
    for i=1:count
      x{i} = nntype.data('format',varargin{i*3-1});
      t{i} = nntype.data('format',varargin{i*3});
      names{i} = varargin{i*3+1};
    end
    args = {net x t names};
  end
end

function plotData = setup_plot(fig)
  PTFS = nnplots.title_font_size;
  plotData.numSignals = 0;
  plotData.axis1 = subplot(2,1,1);
  plotData.axis2 = subplot(2,1,2);
  pos1 = get(plotData.axis1,'position');
  pos2 = get(plotData.axis2,'position');
  
  bottom = pos2(2);
  top = pos1(2) + pos1(4);
  totalHeight = top - bottom;
  topHeight = totalHeight * 0.70;
  middleHeight = totalHeight * 0.05;
  bottomHeight = totalHeight - middleHeight - topHeight;
  pos1(2) = bottom + bottomHeight + middleHeight;
  pos1(4) = topHeight;
  pos2(4) = bottomHeight;
  
  set(plotData.axis1,'position',pos1);
  set(plotData.axis2,'position',pos2);
  
  set(plotData.axis1,'box','on')
  plotData.title1 = title(plotData.axis1,'Function Fit','fontweight','bold','fontsize',PTFS);
  plotData.ylabel1 = ylabel(plotData.axis1,'Output and Target','fontweight','bold','fontsize',PTFS);
  
  set(plotData.axis2,'box','on',...
    'xticklabelmode','manual','xticklabel',{})
  plotData.ylabel2 = ylabel(plotData.axis2,'Error','fontweight','bold','fontsize',PTFS);
  plotData.xlabel2 = xlabel(plotData.axis2,'Input','fontweight','bold','fontsize',PTFS);
  
  windowSize = [700 500];
  screenSize = get(0,'ScreenSize');
  screenSize = screenSize(3:4);
  pos = [(screenSize-windowSize)/2 windowSize];
  set(fig,'position',pos);
end

function fail = unsuitable_to_plot(param,net,x,t,names)
  fail = '';
  x1 = x{1};
  t1 = t{1};
  if numsamples(x1) == 0
    fail = 'The input data has no samples to plot.';
  elseif sum(numelements(x1)) == 0
    fail = 'The input data has no elements to plot.';
  elseif sum(numelements(t1)) == 0
    fail = 'The target data has no elements to plot.';
  elseif sum(numelements(x1)) > 1
    fail = {'The input data has more than one element.','',...
      'This function can only plot single input problems.'};
  elseif (net.numInputDelays > 0)
    fail = {'The network has non-zero input delays.','',...
      'This function can only plot static fit problems.'};
  elseif (net.numLayerDelays > 0)
    fail = {'The network has non-zero layer delays.','',...
      'This function can only plot static fit problems.'};
  elseif numelements(t1) < param.outputIndex
    fail = {...
      sprintf('Output Index is out of range: %g',param.outputIndex),'',...
      sprintf('The target data only has %g elements.',numelements(t1))};
  end
end

function plotData = update_plot(param,fig,plotData,net,xx,tt,names)
  numSignals = length(names);
  if (plotData.numSignals ~= numSignals)
    plotData.numSignals = numSignals;
    cla(plotData.axis1);
    hold(plotData.axis1,'on');
    errorColor = [1 0.6 0];
    fitColor = [0 0 0];
    colors = {[0 0 1],[0 0.8 0],[1 0 0],[1 1 1]*0.5};
    plotData.errorLine = plot(plotData.axis1,[NaN NaN],[NaN NaN],'linewidth',2,...
      'Color',errorColor);
    plotData.fitLine = plot(plotData.axis1,[NaN NaN],[NaN NaN],'LineWidth',1,...
      'Color',fitColor);
    plotData.targetLines = zeros(1,numSignals);
    plotData.outputLines = zeros(1,numSignals);
    targetLegends = cell(1,numSignals);
    outputLegends = cell(1,numSignals);
    for i=1:numSignals
      c = colors{min(i,4)};
      plotData.targetLines(i) = plot(plotData.axis1,[NaN NaN],[NaN NaN],'.',...
        'LineWidth',1.5,'Color',c);
      plotData.outputLines(i) = plot(plotData.axis1,[NaN NaN],[NaN NaN],'+',...
        'Markersize',6,'linewidth',1,'Color',c);
      if ~isempty(names{1})
        targetLegends{i} = [names{i} ' Targets'];
        outputLegends{i} = [names{i} ' Outputs'];
      else
        targetLegends{i} = 'Targets';
        outputLegends{i} = 'Outputs';
      end
    end
    legend(plotData.axis1,[interleave(plotData.targetLines,plotData.outputLines),...
      plotData.errorLine,plotData.fitLine], ...
      [interleave(targetLegends, outputLegends),{'Errors','Fit'}]);
    
    cla(plotData.axis2);
    hold(plotData.axis2,'on');
    plotData.baseLine2 = plot(plotData.axis2,[NaN NaN],[NaN NaN],'k');
    plotData.errorLines2 = zeros(1,numSignals);
    plotData.errorPoints2 = zeros(1,numSignals);
    for i=1:numSignals
      c = colors{min(i,4)};
      plotData.errorLines2(i) = plot(plotData.axis2,[NaN NaN],[NaN NaN],'linewidth',2,...
        'Color',errorColor);
      plotData.errorPoints2(i) = plot(plotData.axis2,[NaN NaN],[NaN NaN],'.',...
        'LineWidth',1.5,'Color',c);
    end
  end
  
  X = cell(1,numSignals);
  Y = cell(1,numSignals);
  T = cell(1,numSignals);
  for i=1:numSignals
    x = cell2mat(xx{i});
    t = cell2mat(getelements(tt{i},param.outputIndex));
    y = nncalc.y(net,{x});
    y = getelements(cell2mat(y),param.outputIndex);
    
    nani = find(isnan(t));
    x(nani) = [];
    t(nani) = [];
    y(nani) = [];
    
    X{i} = x;
    T{i} = t;
    Y{i} = y;
    set(plotData.outputLines(i),'xdata',x,'ydata',y);
    set(plotData.targetLines(i),'xdata',x,'ydata',t);
    
    e = t-y;
    q = length(e);
    ydata = reshape([e; zeros(1,q); nan(1,q)],1,q*3);
    xdata = reshape([x; x; nan(1,q)],1,q*3);
    set(plotData.errorLines2(i),'xdata',xdata,'ydata',ydata);
    xdata = x; %[x x];
    ydata = e; %[e zeros(1,q)];
    set(plotData.errorPoints2(i),'xdata',xdata,'ydata',ydata);
  end
  X = [X{:}];
  Y = [Y{:}];
  T = [T{:}];
  xmin = min(X);
  xmax = max(X);
  extend = (xmax-xmin)*0;
  xlim = [xmin-extend,xmax+extend];
  x = linspace(xlim(1),xlim(2),1000);
  y = nncalc.y(net,{x});
  y = getelements(cell2mat(y),param.outputIndex);
  set(plotData.fitLine,'xdata',x,'ydata',y);
  numPoints = length(X);
  spaces = nan(1,numPoints);
  X = [X; X; spaces];
  Y = [Y; T; spaces];
  X = X(:)';
  Y = Y(:)';
  set(plotData.errorLine,'xdata',X,'ydata',Y);
  set(plotData.axis1,'xlim',xlim);
  set(plotData.axis1,'ylimmode','auto');
  set(plotData.title1,'string',...
    sprintf('Function Fit for Output Element %g',param.outputIndex));
  
  set(plotData.axis2,'xlim',xlim);
  set(plotData.axis2,'ylimmode','auto');
  set(plotData.baseLine2,'xdata',xlim,'ydata',[0 0]);
  legend(plotData.axis2,plotData.errorPoints2(1),'Targets - Outputs');
end

% SUPPORT

function y = interleave(a,b)
  y = reshape([a;b],1,2*length(a));
end
