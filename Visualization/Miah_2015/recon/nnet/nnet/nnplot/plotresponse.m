function out1 = plotresponse(varargin)
%PLOTRESPONSE Plot dynamic network time-series response.
%
% <a href="matlab:doc plotresponse">plotresponse</a>(targets,outputs) takes time series target and output data
% and plots the time series response.
%
% <a href="matlab:doc plotresponse">plotresponse</a>(targets1,name1,targets2,name2,...,outputs) takes multiple
% sets of target data.  Each set must be the same size as the output data
% and in every respective position only one set may have a finite value
% while the other sets have NaN.
%
% <a href="matlab:doc plotresponse">plotresponse</a>(targets,outputs,'outputIndex',outputIndex,'sampleIndex',sampleIndex)
% plots using optional parameters that override the default output element
% index (1), and the default sample/series index (1).
%
% Here a NARX network is used to solve a time series problem.
%
%   [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%   net = <a href="matlab:doc narxnet">narxnet</a>(1:2,10);
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%   Y = net(Xs,Xi,Ai);
%   <a href="matlab:doc plotresponse">plotresponse</a>(Ts,Y)
%
% See also nncorr, plotinerrcorr, ploterrhist.

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
  info = nnfcnPlot(mfilename,'Time-Series Response',7.0,[...
  nnetParamInfo('outputIndex','Output Index','nntype.pos_int_scalar',1,...
      'Index of output/target element to plot.'), ...
  nnetParamInfo('sampleIndex','Sample Index','nntype.pos_int_scalar',1,...
      'Index of the time-series sample to plot.'), ...
  ]);
end

function args = training_args(net,tr,data)
  y = nncalc.y(net,data.X,data.Xi,data.Ai);
  tt = {gmultiply(data.train.mask,data.T)};
  names = {'Training'};
  if ~isempty(data.val.indices)
    tt = [tt {gmultiply(data.val.mask,data.T)}];
    names = [names {'Validation'}];
  end
  if ~isempty(data.test.indices)
    tt = [tt {gmultiply(data.test.mask,data.T)}];
    names = [names {'Test'}];
  end
  args = {y tt names net.sampleTime};
end

function args = standard_args(varargin)
  if nargin < 2
    args = 'Not enough input arguments.';
    return;
  end
  if nargin > 2
    z = varargin{end};
    if nntype.pos_int_scalar('isa',z)
      sampleTime = z;
      varargin(end) = [];
    else
      sampleTime = 1;
    end
  end
  if nargin == 2
    % plotresponse(t,y)
    t = nntype.data('format',varargin{1});
    y = nntype.data('format',varargin{2});
    if nargin < 3, sampleTime = 1; else sampleTime = varargin{3}; end
    err = nntype.data('check',y);
    if ~isempty(err),nnerr.throw(nnerr.value(err,'Outputs')); end
    err = nntype.data('check',t);
    if ~isempty(err),nnerr.throw(nnerr.value(err,'Targets')); end
    args = {y {t} {''} sampleTime};
  else
    y = nntype.data('format',varargin{end});
    varargin(end) = [];
    count = length(varargin)/2;
    if length(varargin) ~= (count*2)
      error(message('nnet:Args:IncorrectNum'));
    end
    tt = cell(1,count);
    names = cell(1,count);
    for i=1:count
      tt{i} = nntype.data('format',varargin{i*2-1});
      names{i} = nntype.string('format',varargin{i*2});
    end
    args = {y,tt,names,sampleTime};
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
  
  set(plotData.axis1,'box','on',...
    'xticklabelmode','manual','xticklabel',{})
  plotData.title1 = title(plotData.axis1,'Time-Series Response','fontweight','bold','fontsize',PTFS);
  plotData.ylabel1 = ylabel(plotData.axis1,'Output and Target','fontweight','bold','fontsize',PTFS);

  set(gca,'box','on')
  plotData.ylabel2 = ylabel(plotData.axis2,'Error','fontweight','bold','fontsize',PTFS);
  plotData.xlabel2 = xlabel(plotData.axis2,'Time','fontweight','bold','fontsize',PTFS);
  
  windowSize = [700 500];
  screenSize = get(0,'ScreenSize');
  screenSize = screenSize(3:4);
  pos = [(screenSize-windowSize)/2 windowSize];
  set(fig,'position',pos);
end

function fail = unsuitable_to_plot(param,y,tt,names,sampleTime)
  fail = '';
  t1 = tt{1};
  if numsamples(t1) == 0
    fail = 'The target data has no samples to plot.';
  elseif sum(numelements(t1)) == 0
    fail = 'The target data has no elements to plot.';
  elseif numtimesteps(t1) == 0
    fail = 'The input data has no timesteps to plot.';
  elseif numelements(t1) < param.outputIndex
    fail = {...
      sprintf('Output Index is out of range: %g',param.outputIndex),'',...
      sprintf('The target data only has %g elements.',numelements(t1))};
  elseif numsamples(t1) < param.outputIndex
    fail = {...
      sprintf('Sample Index is out of range: %g',param.outputIndex),'',...
      sprintf('The target data only has %g elements.',numelements(t1))};
  end
end

function plotData = update_plot(param,fig,plotData,yy,tt,names,sampleTime)
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
      [interleave(targetLegends, outputLegends),{'Errors','Response'}]);
    
    cla(plotData.axis2);
    hold(plotData.axis2,'on')
    plotData.baseLine2 = plot(plotData.axis2,[NaN NaN],[NaN NaN],'k');
    plotData.errorLines2 = cell(1,numSignals);
    plotData.errorPoints2 = cell(1,numSignals);
    for i=1:numSignals
      c = colors{min(i,4)};
      plotData.errorLines2{i} = plot(plotData.axis2,[NaN NaN],[NaN NaN],'linewidth',2,...
        'Color',errorColor);
      plotData.errorPoints2{i} = plot(plotData.axis2,[NaN NaN],[NaN NaN],'.',...
        'LineWidth',1.5,'Color',c);
    end
  end
  
  TIME = cell(1,numSignals);
  Y = cell(1,numSignals);
  T = cell(1,numSignals);
  yy = nnfast.getsamples(yy,param.sampleIndex);
  yy = nnfast.getelements(yy,param.outputIndex);
  yy = cell2mat(yy);
  for i=1:numSignals
    t = nnfast.getsamples(tt{i},param.sampleIndex);
    t = getelements(t,param.outputIndex);
    t = cell2mat(t);
    y = yy;
    TS = size(t,2);
    time = (1:TS)*sampleTime;
  
    nani = find(isnan(t));
    t(nani) = [];
    y(nani) = [];
    time(nani) = [];
    
    TIME{i} = time;
    T{i} = t;
    Y{i} = y;
    set(plotData.outputLines(i),'xdata',time,'ydata',y);
    set(plotData.targetLines(i),'xdata',time,'ydata',t);
    
    e = t-y;
    q = length(e);
    ydata = reshape([e; zeros(1,q); nan(1,q)],1,q*3);
    xdata = reshape([time; time; nan(1,q)],1,q*3);
    set(plotData.errorLines2{i},'xdata',xdata,'ydata',ydata);
    xdata = time; %[time time];
    ydata = e; %[e zeros(1,q)];
    set(plotData.errorPoints2{i},'xdata',xdata,'ydata',ydata);
  end
  TIME = [TIME{:}];
  Y = [Y{:}];
  T = [T{:}];
  time = (1:TS)*sampleTime;
  set(plotData.fitLine,'xdata',time,'ydata',yy);
  numPoints = length(Y);
  spaces = nan(1,numPoints);
  TIME = [TIME; TIME; spaces];
  Y = [Y; T; spaces];
  TIME = TIME(:)';
  Y = Y(:)';
  xlim = minmax(TIME);
  if (xlim(1) == xlim(2)), xlim = xlim + [-1 1]; end
  set(plotData.errorLine,'xdata',TIME,'ydata',Y);
  set(plotData.axis1,'xlim',xlim);
  set(plotData.axis1,'ylimmode','auto');
  set(plotData.title1,'string',...
    sprintf('Response of Output Element %g for Time-Series %g',...
    param.outputIndex,param.sampleIndex));
  
  set(plotData.axis2,'xlim',xlim);
  set(plotData.axis2,'ylimmode','auto');
  set(plotData.baseLine2,'xdata',xlim,'ydata',[0 0]);
  legend(plotData.axis2,plotData.errorPoints2{1},'Targets - Outputs');
end

% SUPPORT

function y = interleave(a,b)
  y = reshape([a;b],1,2*length(a));
end
