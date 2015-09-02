function out1 = plotconfusion(varargin)
%PLOTCONFUSION Plot classification confusion matrix.
%
% <a href="matlab:doc plotconfusion">plotconfusion</a>(targets,outputs) takes a target and output data in
% 1-of-N form (each column vector is all zeros with a single 1 indicating
% the class number), and generates a confusion plot.
%
% <a href="matlab:doc plotconfusion">plotconfusion</a>(targets1,outputs1,'name1',targets2,outputs2,'name2',...)
% generates a variable number of confusion plots in one figure.
%
% Here a pattern recognition network is trained and its accuracy plotted:
%
%   [x,t] = <a href="matlab:doc simpleclass_dataset">simpleclass_dataset</a>;
%   net = <a href="matlab:doc patternnet">patternnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   y = net(x);
%   <a href="matlab:doc plotconfusion">plotconfusion</a>(t,y);
%
% See also confusion, plotroc, ploterrhist, plotregression.

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
  info = nnfcnPlot(mfilename,'Confusion',7.0,[]);
end

function args = training_args(net,tr,data)
  yall  = nncalc.y(net,data.X,data.Xi,data.Ai);
  y = {yall};
  t = {gmultiply(data.train.mask,data.T)};
  names = {'Training'};
  if ~isempty(data.val.enabled)
    y = [y {yall}];
    t = [t {gmultiply(data.val.mask,data.T)}];
    names = [names {'Validation'}];
  end
  if ~isempty(data.test.enabled)
    y = [y {yall}];
    t = [t {gmultiply(data.test.mask,data.T)}];
    names = [names {'Test'}];
  end
  if length(t) >= 2
    t = [t {data.T}];
    y = [y {yall}];
    names = [names {'All'}];
  end
  args = {t y names};
end

function args = standard_args(varargin)
  if nargin < 2
    args = 'Not enough input arguments.';
  elseif (nargin > 2) && (rem(nargin,3) ~= 0)
    args = 'Incorrect number of input arguments.';
  elseif nargin == 2
    % (t,y)
    t = { nntype.data('format',varargin{1}) };
    y = { nntype.data('format',varargin{2}) };
    names = {''};
    args = {t y names};
  else
    % (t1,y1,name1,...)
    % TODO - Check data is consistent
    count = nargin/3;
    t = cell(1,count);
    y = cell(1,count);
    names = cell(1,count);
    for i=1:count
      t{i} = nntype.data('format',varargin{i*3-2});
      y{i} = nntype.data('format',varargin{i*3-1});
      names{i} = varargin{i*3};
    end
    args = {t y names};
  end
end

function plotData = setup_plot(fig)
  plotData.numSignals = 0;
end

function fail = unsuitable_to_plot(param,t,y,names)
  fail = '';
end

function plotData = update_plot(param,fig,plotData,tt,yy,names)
  PTFS = nnplots.title_font_size;
  trainColor = [0 0 1];
  valColor = [0 1 0];
  testColor = [1 0 0];
  colors = {trainColor valColor testColor};
  t = tt{1}; if iscell(t), t = cell2mat(t); end
  numSignals = length(names);
  [numClasses,numSamples] = size(t);
  numClasses = max(numClasses,2);
  numColumns = numClasses+1;
  % Rebuild figure
  if (plotData.numSignals ~= numSignals) || (plotData.numClasses ~= numClasses)
    plotData.numSignals = numSignals;
    plotData.numClasses = numClasses;
    plotData.axes = zeros(1,numSignals);
    titleStyle = {'fontweight','bold','fontsize',PTFS};
    plotcols = ceil(sqrt(numSignals));
    plotrows = ceil(numSignals/plotcols);
    set(fig,'nextplot','replace')
    for plotrow=1:plotrows
      for plotcol=1:plotcols
        i = (plotrow-1)*plotcols+plotcol;
        if (i<=numSignals)
          a = subplot(plotrows,plotcols,i);
          set(a,'ydir','reverse','ticklength',[0 0],'box','on')
          %set(a,'XAxisLocation','top')
          set(a,'dataaspectratio',[1 1 1])
          hold on
          mn = 0.5;
          mx = numColumns+0.5;
          labels = cell(1,numColumns);
          if size(t,1) == 1
            base = 0;
          else
            base = 1;
          end
          for j=1:numClasses, labels{j} = num2str(base+j-1); end
          labels{numColumns} = '';
          set(a,'xlim',[mn mx],'xtick',1:(numColumns+1));
          set(a,'ylim',[mn mx],'ytick',1:(numColumns+1));
          set(a,'xticklabel',labels);
          set(a,'yticklabel',labels);
          nngray = [167 167 167]/255;
          axisdata.number = zeros(numColumns,numColumns);
          axisdata.percent = zeros(numColumns,numColumns);
          for j=1:numColumns
            for k=1:numColumns
            if (j==numColumns) && (k==numColumns)
              c = nngui.blue;
              topcolor = [0 0.4 0];
              bottomcolor = [0.4 0 0];
              topbold = 'bold';
              bottombold = 'bold';
            elseif (j==k)
              c = nngui.green;
              topcolor = [0 0 0];
              bottomcolor = [0 0 0];
              topbold = 'bold';
              bottombold = 'normal';
            elseif (j<numColumns) && (k<numColumns)
              c = nngui.red;
              topcolor = [0 0 0];
              bottomcolor = [0 0 0];
              topbold = 'bold';
              bottombold = 'normal';
            elseif (j<numColumns)
              c = [0.5 0.5 0.5];
              topcolor = [0 0.4 0];
              bottomcolor = [0.4 0 0];
              topbold = 'normal';
              bottombold = 'normal';
            else
              c = [0.5 0.5 0.5];
              topcolor = [0 0.4 0];
              bottomcolor = [0.4 0 0];
              topbold = 'normal';
              bottombold = 'normal';
            end
            fill([0 1 1 0]-0.5+j,[0 0 1 1]-0.5+k,c);
            axisdata.number(j,k) = text(j,k,'', ...
              'horizontalalignment','center',...
              'verticalalignment','bottom',...
              'FontWeight',topbold,...
              'color',topcolor); %,...
              %'FontSize',8);
            axisdata.percent(j,k) = text(j,k,'', ...
              'horizontalalignment','center',...
              'verticalalignment','top',...
              'FontWeight',bottombold,...
              'color',bottomcolor); %,...
              %'FontSize',8);
            end
          end
          plot([0 0]+numColumns-0.5,[mn mx],'linewidth',2,'color',[0 0 0]+0.25);
          plot([mn mx],[0 0]+numColumns-0.5,'linewidth',2,'color',[0 0 0]+0.25);
          xlabel('Target Class',titleStyle{:});
          ylabel('Output Class',titleStyle{:});
          title([names{i} ' Confusion Matrix'],titleStyle{:});
          set(a,'userdata',axisdata);
          plotData.axes(i) = a;
        end
      end
    end
    screenSize = get(0,'ScreenSize');
    screenSize = screenSize(3:4);
    if numSignals == 1
      windowSize = [500 500];
    else
      windowSize = 700 * [1 (plotrows/plotcols)];
    end
    pos = [(screenSize-windowSize)/2 windowSize];
    set(fig,'position',pos);
  end

  % Fill axes
  for i=1:numSignals
    a = plotData.axes(i);
    set(fig,'CurrentAxes',a);
    axisdata = get(a,'userdata');
    y = yy{i}; if iscell(y), y = cell2mat(y); end
    t = tt{i}; if iscell(t), t = cell2mat(t); end
    known = find(~isnan(sum(t,1)));
    y = y(:,known);
    t = t(:,known);
    numSamples = size(t,2);
    [c,cm] = confusion(t,y);
    for j=1:numColumns
      for k=1:numColumns
        if (j==numColumns) && (k==numColumns)
          correct = sum(diag(cm));
          perc = correct/numSamples;
          top = percent_string(perc);
          bottom = percent_string(1-perc);
        elseif (j==k)
          num = cm(j,k);
          top = num2str(num);
          perc = num/numSamples;
          bottom = percent_string(perc);
        elseif (j<numColumns) && (k<numColumns)
          num = cm(j,k);
          top = num2str(num);
          perc = num/numSamples;
          bottom = percent_string(perc);
        elseif (j<numColumns)
          correct = cm(j,j);
          total = sum(cm(j,:));
          perc = correct/total;
          top = percent_string(perc);
          bottom = percent_string(1-perc);
        else
          correct = cm(k,k);
          total = sum(cm(:,k));
          perc = correct/total;
          top = percent_string(perc);
          bottom = percent_string(1-perc);
        end
        set(axisdata.number(j,k),'string',top);
        set(axisdata.percent(j,k),'string',bottom);
      end
    end
  end
end

function ps = percent_string(p)
  if (p==1)
    ps = '100%';
  else
    ps = [sprintf('%2.1f',p*100) '%'];
  end
end
