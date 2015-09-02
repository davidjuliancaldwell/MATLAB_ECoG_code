function out1 = plotperform(varargin)
%PLOTPERFORM Plot network performance.
%
% <a href="matlab:doc plotperform">plotperform</a>(trainingRecord) plots the training record returned
% by the function TRAIN or a specific training function.
%
% Here a feed-forward network is used to solve a simple problem:
%
%   [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%   net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%   [net,tr] = <a href="matlab:doc train">train</a>(net,x,t);
%   <a href="matlab:doc plotperform">plotperform</a>(tr)
%
% See also plottrainstate.

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
  info = nnfcnPlot(mfilename,'Performance',7.0,[]);
end

function args = training_args(net,tr,data,param)
  args = {tr};
end

function args = standard_args(varargin)
  if nargin == 0
    args = 'Not enough input arguments.';
  elseif nargin > 1
    args = 'Too many input arguments.';
  else
    tr = varargin{1};
    args = {tr};
  end
end

function figData = setup_plot(fig)
  PTFS = nnplots.title_font_size;
  trainColor = [0 0 1];
  valColor = [0 0.8 0];
  testColor = [1 0 0];
  goalColor = [0 0 0];
  hold on
  figData.trainLine = plot([NaN NaN],[NaN NaN],'b','LineWidth',2,'Color',trainColor);
  figData.valLine = plot([NaN NaN],[NaN NaN],'g','LineWidth',2,'Color',valColor);
  figData.testLine = plot([NaN NaN],[NaN NaN],'r','LineWidth',2,'Color',testColor);
  figData.bestLine = plot([NaN NaN],[NaN NaN],':','Color',valColor);
  figData.bestSpot = plot([NaN NaN],[NaN NaN],'o','Color',valColor,'markersize',16,'linewidth',1.5);
  figData.goalLine = plot([NaN NaN],[NaN NaN],':','Color',goalColor);
  figData.title = title('Best Performance','fontweight','bold','fontsize',PTFS);
  figData.ylabel = ylabel('Performance','fontweight','bold','fontsize',PTFS);
  figData.xlabel = xlabel('Epochs','fontweight','bold','fontsize',PTFS);
  figData.axis = gca;
  set(figData.axis,'yscale','log');
end

function fail = unsuitable_to_plot(param,tr)
  fail = '';
end

function figData = update_plot(param,fig,figData,tr)
  trainColor = [0 0 1];
  valColor = [0 0.8 0];
  numEpochs = tr.num_epochs;
  ind = 1:(numEpochs+1);
  goal = tr.goal;
  if (goal <= 0), goal = NaN; end
  epochs = tr.epoch(ind);
  perf = tr.perf(ind);
  vperf = tr.vperf(ind);
  tperf = tr.tperf(ind);
  bestEpoch = tr.best_epoch;
  if isnan(vperf(1))
    bestPerf = perf(bestEpoch+1);
    bestColor = trainColor * 0.6;
    bestMode = 'Training';
  else
    bestPerf = vperf(bestEpoch+1);
    bestColor = valColor * 0.6;
    bestMode = 'Validation';
  end
  xlim = [0 max(1,numEpochs)];
  ylim = calculate_y_limit(perf,vperf,tperf,goal);
  set(figData.trainLine,'Xdata',epochs,'Ydata',perf);
  set(figData.valLine,'Xdata',epochs,'Ydata',vperf);
  set(figData.testLine,'Xdata',epochs,'Ydata',tperf);
  set(figData.bestLine,'Xdata',[bestEpoch bestEpoch NaN xlim])
  set(figData.bestLine,'Ydata',[ylim NaN bestPerf bestPerf]);
  set(figData.bestLine,'Color',bestColor);
  set(figData.bestSpot,'Xdata',bestEpoch,'Ydata',bestPerf);
  set(figData.bestSpot,'Color',bestColor);
  set(figData.goalLine,'Xdata',xlim,'Ydata',[goal goal]);
  set(figData.axis,'xlim',xlim);
  set(figData.axis,'ylim',ylim);
  legendLines = [figData.trainLine];
  legendNames = {'Train'};
  if ~isnan(vperf(1))
    legendLines = [legendLines figData.valLine];
    legendNames = [legendNames 'Validation'];
  end
  if ~isnan(tperf(1))
    legendLines = [legendLines figData.testLine];
    legendNames = [legendNames 'Test'];
  end
  legendLines = [legendLines figData.bestLine];
  legendNames = [legendNames 'Best'];
  if ~isnan(goal)
    legendLines = [legendLines figData.goalLine];
    legendNames = [legendNames 'Goal'];
  end
  legend(legendLines,legendNames);
  performInfo = feval(tr.performFcn,'info');
  set(figData.title,'String',['Best ' bestMode ' Performance is ' num2str(bestPerf) ' at epoch ' num2str(bestEpoch)])
  set(figData.ylabel,'String',[performInfo.name '  (' performInfo.mfunction ')'])
  set(figData.xlabel,'String',[num2str(numEpochs) ' Epochs'])
end

%% UTILITY FUNCTIONS

function ylim = calculate_y_limit(perf,vperf,tperf,goal)
  ymax = max([perf vperf tperf goal]);
  ymin = min([perf vperf tperf goal]);
  ymax = 10^ceil(log10(ymax));
  ymin = 10^fix(log10(ymin)-1);
  if (ymin == ymax)
    ylim = ymin + [0 1];
  else
    ylim = [ymin*0.9 ymax*1.1];
  end
end
