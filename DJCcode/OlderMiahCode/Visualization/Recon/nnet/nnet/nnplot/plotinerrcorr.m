function out1 = plotinerrcorr(varargin)
%PLOTINERRCORR Plot input to error time series cross-correlation.
%
% <a href="matlab:doc plotinerrcorr">plotinerrcorr</a>(inputs,errors) takes input and error data and plots
% the cross-correlation between them.
%
% <a href="matlab:doc plotinerrcorr">plotinerrcorr</a>(errors,'inputIndex',inputIndex,'outputIndex',outputIndex)
% plots using optional parameters that override the default input index (1)
% and output index (1).
%
% Here a NARX network is used to solve a time series problem.
%
%   [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%   net = <a href="matlab:doc narxnet">narxnet</a>(1:2,10);
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%   Y = net(Xs,Xi,Ai);
%   E = <a href="matlab:doc gsubtract">gsubtract</a>(Ts,Y);
%   <a href="matlab:doc ploterrcorr">ploterrcorr</a>(E)
%   <a href="matlab:doc plotinerrcorr">plotinerrcorr</a>(Xs,E)
%
% See also nncorr, ploterrcorr, ploterrhist.

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
  info = nnfcnPlot(mfilename,'Input-Error Cross-correlation',7.0,[...
    nnetParamInfo('inputIndex','Input Index','nntype.pos_int_scalar',1,...
      'Index of input element to plot.'), ...
    nnetParamInfo('outputIndex','Output Index','nntype.pos_int_scalar',1,...
      'Index of error element to plot.'), ...
    ]);
end

function args = training_args(net,tr,data)
  x = data.X;
  y = nncalc.y(net,data.X,data.Xi,data.Ai);
  t = data.T;
  e = gsubtract(y,t);
  args = {{x},{e},{''},{[0 0 1]},' = Target %g - Output %g';};
%   trainColor = [0 0 1];
%   x = {data.X};
%   t = gmultiply(data.T,data.train.mask);
%   if data.options.flattenedTime, t = con2seq(t{1}); end
%   e = {gsubtract(y,t)};
%   names = {'Training'};
%   colors = {trainColor};
%   if ~isempty(data.val.enabled)
%     valColor = [0 0.8 0];
%     x = [x {data.X}];
%     t = gmultiply(data.T,data.val.mask);
%     if data.options.flattenedTime, t = con2seq(t{1}); end
%     e = [e {gsubtract(y,t)}];
%     names = [names {'Validation'}];
%     colors = [colors {valColor}];
%   end
%   if ~isempty(data.test.enabled)
%     testColor = [1 0 0];
%     x = [x {data.X}];
%     t = gmultiply(data.T,data.test.mask);
%     if data.options.flattenedTime, t = con2seq(t{1}); end
%     e = [e {gsubtract(y,t)}];
%     names = [names {'Test'}];
%     colors = [colors {testColor}];
%   end
%   if length(names) >= 2
%     allColor = [0.6 0.6 0.6];
%     x = [x {data.X}];
%     t = data.T;
%     if data.options.flattenedTime, t = con2seq(data.T{1}); end
%     e = [e {gsubtract(y,t)}];
%     names = [names {'All'}];
%     colors = [colors {allColor}];
%   end
%   args = {x,e,names,colors};
end

function args = standard_args(varargin)
  lastArg = varargin{end};
  if ischar(lastArg) && strcmp(lastArg,'T-Y')
    note = ' = Target %g - Output %g';
    varargin(end) = [];
  else
    note = '';
  end
  if length(varargin) < 2
    args = 'Not enough input arguments.';
  elseif length(varargin) > 2
    args = 'Too many input arguments.';
  else
    x = varargin{1};
    if isnumeric(x) || islogical(x)
      x = con2seq(x);
      % TODO - STRICTNNDATATS to handle this case
    end
    x = nntype.data('format',x);
    e = varargin{2};
    if isnumeric(e) || islogical(e)
      e = con2seq(e);
      % TODO - STRICTNNDATATS to handle this case
    end
    e = nntype.data('format',e);
    args = {{x},{e},{''},{[0 0 1]},note};
  end
end

function plotData = setup_plot(fig)
  PTFS = nnplots.title_font_size;
  
  barWidths = [0.4 0.6 0.8 1.0];
  
  plotData.axis = subplot(1,1,1);
  plotData.title = title('Input to Error Correlations','fontweight','bold','fontsize',PTFS);
  plotData.ylabel = ylabel('Correlation','fontweight','bold','fontsize',PTFS);
  plotData.xlabel = xlabel('Lag','fontweight','bold','fontsize',PTFS);
  
  hold on
  plotData.bars = cell(1,4);
  for i=4:-1:1
    plotData.bars{i} = bar([-1 1],[0 0],barWidths(i),...
      'visible','off','edgecolor','none');
  end
  plotData.numSignals = 0;
  plotData.baseLine = plot([-1 1],[0 0],'k');
  plotData.overLine = plot([-1 1],[1 1],':r');
  plotData.underLine = plot([-1 1],[-1 -1],':r');
     
  windowSize = [800 400];
  screenSize = get(0,'ScreenSize');
  screenSize = screenSize(3:4);
  pos = [(screenSize-windowSize)/2 windowSize];
  set(fig,'position',pos);
end

function fail = unsuitable_to_plot(param,x,e,names,colors,note)
  fail = '';
  x1 = x{1};
  e1 = e{1};
  if length(x) > 4
    fail = 'Cannot plot more than four signals.';
  elseif numsamples(x1) == 0
    fail = 'No samples to plot.';
  elseif numtimesteps(x1) == 0
    fail = 'No timesteps to plot.';
  elseif numtimesteps(x1) == 0
    fail = 'No multiple timesteps to plot.';
  elseif sum(numelements(x1)) == 0
    fail = 'Input data does not have any elements.';
  elseif sum(numelements(e{1})) == 0
    fail = 'Error data does not have any elements.';
  elseif numelements(x1) < param.inputIndex
    fail = {...
      sprintf('Input Index is out of range: %g',param.inputIndex),'',...
      sprintf('The input data only has %g elements.',numelements(x1))};
  elseif numelements(e1) < param.outputIndex
    fail = {...
      sprintf('Output Index is out of range: %g',param.outputIndex),'',...
      sprintf('The error data only has %g elements.',numelements(e1))};
  end
end

function plotData = update_plot(param,fig,plotData,x,e,names,colors,note)

  axis(plotData.axis);
  numSignals = length(e);
  if numSignals ~= plotData.numSignals
    plotData.numSignals = numSignals;
    if (numSignals == 1) && isempty(names{1})
      legend('off')
    else
      legend([plotData.bars{1:numSignals}],names{:});
    end
    for i=1:numSignals
      set(plotData.bars{i},'visible','on');
    end
    for i=(numSignals+1):4
      set(plotData.bars{i},'visible','off');
    end
  end
  maxlag = 0;
  ymin = 0;
  ymax = 0;
  confint = 0;
  for i=1:numSignals
    xi = nnfast.getelements(x{i},param.inputIndex);
    ei = nnfast.getelements(e{i},param.outputIndex);
    maxlagi = min(20,numtimesteps(xi)-1);
    maxlag = max(maxlag,maxlagi);
    corr = nncorr(xi,ei,maxlagi,'unbiased');
    corr = corr{1,1};
    confint = confint + std(cell2mat(xi))*std(cell2mat(ei))*2/sqrt(length(ei)); 
    ymin = min(ymin,min(corr));
    ymax = max(ymax,max(corr));
    set(plotData.bars{i},'xdata',-maxlagi:maxlagi,'ydata',corr);
    set(plotData.bars{i},'edgecolor','none','facecolor',colors{i});
  end
  xlim = [-maxlag-1 maxlag+1];
  confint = confint / numSignals;
  ylim = [min(-confint,ymin) max(confint,ymax)];
  ylim = ylim + ((ylim(2)-ylim(1))*0.1*[-1 1]);
  confint = [confint confint];
  set(plotData.baseLine,'xdata',xlim);
  set(plotData.overLine,'xdata',xlim,'ydata',confint);
  set(plotData.underLine,'xdata',xlim,'ydata',-confint);
  set(plotData.axis,'xlim',xlim,'ylim',ylim);
  
  numGs = length(strfind(note,'%g'));
  note = sprintf(note,zeros(1,numGs)+param.outputIndex);
  set(plotData.title,'string',...
    sprintf(['Correlation between Input %g and Error %g' note],...
    param.inputIndex,param.outputIndex));
  
  legend([plotData.bars{1} plotData.baseLine plotData.overLine],...
    'Correlations','Zero Correlation','Confidence Limit')
end
