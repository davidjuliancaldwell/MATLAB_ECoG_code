function out1 = plottrainstate(varargin)
%PLOTTRAINSTATE Plot training state values.
%
% <a href="matlab:doc plottrainstate">plottrainstate</a>(trainingRecord) plots the training states returned
% by the function TRAIN or a specific training function.
%
% Here a feed-forward network is used to solve a simple problem:
%
%   [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%   net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%   [net,tr] = <a href="matlab:doc train">train</a>(net,x,t);
%   y = net(x)
%   <a href="matlab:doc plottrainstate">plottrainstate</a>(tr)
%
% See also plotperform.

% Copyright 2007-2011 The MathWorks, Inc.

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
  info = nnfcnPlot(mfilename,'Training State',7.0,[]);
end

function args = training_args(net,tr,signals)
  args = {tr};
end

function args = standard_args(varargin)
  if nargin < 1
    args = 'Not enough input arguments.';
  else
    tr = varargin{1};
    args = {tr};
  end
end

function plotData = setup_plot(fig)
  plotData.trainFcn = '';
end

function fail = unsuitable_to_plot(param,net)
  fail = '';
  % TODO
end

function plotData = update_plot(param,fig,plotData,tr)

  trainInfo = feval(tr.trainFcn,'info');
  numAxes = length(trainInfo.states);
  if ~strcmp(plotData.trainFcn,tr.trainFcn);
    set(fig,'nextplot','replace');
    plotData.trainFcn = tr.trainFcn;
    plotData.numAxes = numAxes;
    plotData.axes = zeros(1,numAxes);
    plotData.lines = zeros(1,numAxes);
    plotData.titles = zeros(1,numAxes);
    for i=1:numAxes
      state = trainInfo.states(i);
      name = state.name;
      name(name == '_') = ' ';
      a = subplot(numAxes,1,i);
      plotData.axes(i) = a;
      axes(a);
      cla;
      plotData.lines(i) = plot([NaN NaN],[NaN NaN],'linewidth',2,'markerfacecolor',[1 0 0]);
      ylabel(name);
      if (i == numAxes), xlabel('Epochs'); end
      if (i < numAxes), set(gca,'xticklabel',[]); end
      plotData.titles(i) = title([state.title ' = ?']);
      hold on
    end
  end

  numEpochs = tr.num_epochs;
  len = numEpochs+1;
  ind = 1:len;

  numAxes = length(trainInfo.states);
  epochs = tr.epoch(ind);
  for i=1:numAxes
    state = trainInfo.states(i);
    name = state.name;
    values = tr.(name)(ind);

    set(plotData.lines(i),'Xdata',epochs,'Ydata',values);
    if strcmp(state.form,'discrete')
      set(plotData.lines(i),'marker','diamond','linestyle','none','linewidth',1);
    else
      set(plotData.lines(i),'marker','none','linestyle','-','linewidth',2);
    end

    set(plotData.axes(i),'xlim',[0 max(numEpochs,1)])
    set(plotData.axes(i),'yscale',state.scale);
    set(plotData.titles(i),'string',[state.title ' = ' ...
      num2str(values(end)) ', at epoch ' num2str(numEpochs)]);

    axis(plotData.axes(i));
    if (i == numAxes)
      xlabel([num2str(numEpochs) ' Epochs']);
    else 
      xlabel('');
    end
  end
  drawnow
end

