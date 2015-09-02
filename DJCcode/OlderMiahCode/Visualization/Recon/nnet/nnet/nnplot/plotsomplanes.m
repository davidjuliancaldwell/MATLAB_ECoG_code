function out1 = plotsomplanes(varargin)
%PLOTSOMPLANES Plot self-organizing map weight planes.
%
% <a href="matlab:doc plotsomplanes">plotsomplanes</a>(net) takes a self-organizing map network and creates a
% plot for each input element i, showing how strongly different areas of
% the map connect to input i negatively or positively.
%
% Here a self-organizing map is trained to classify iris flowers:
%
%    x = <a href="matlab:doc iris_dataset">iris_dataset</a>;
%    net = <a href="matlab:doc selforgmap">selforgmap</a>([8 8]);
%    net = <a href="matlab:doc train">train</a>(net,x);
%    y = net(x)
%    <a href="matlab:doc plotsomplanes">plotsomplanes</a>(net,x);
%
% See also plotwb, plotsomhits, plotsomnc, plotsomnd, plotsompos,
% plotsomtop.


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
  info = nnfcnPlot(mfilename,'SOM Input Planes',7.0,[]);
end

function args = training_args(net,tr,data)
  args = {net};
end

function args = standard_args(varargin)
  net = varargin{1};
  args = {net};
end

function plotData = setup_plot(fig)
  plotData.axis = subplot(1,1,1);
  plotData.numInputs = 0;
  plotData.numNeurons = 0;
  plotData.topologyFcn = '';
end

function fail = unsuitable_to_plot(param,net,input)
  if (net.numLayers < 1)
    fail = 'Network has no layers.';
  elseif (net.layers{1}.size == 0)
    fail = 'Layer has no neurons.';
  elseif isempty(net.layers{1}.distanceFcn)
    fail = 'Layer 1 does not have a distance function.';
  elseif isempty(net.layers{1}.topologyFcn)
    fail = 'Layer 1 does not have a topology function.';
  else
    fail = '';
  end
end

function plotData = update_plot(param,fig,plotData,net)
  numInputs = net.inputs{1}.processedSize;
  numNeurons = net.layers{1}.size;
  topologyFcn = net.layers{1}.topologyFcn;

  if strcmp(topologyFcn,'gridtop')
    shapex = [-1 1 1 -1]*0.5;
    shapey = [1 1 -1 -1]*0.5;
    dx = 1;
    dy = 1;
  elseif strcmp(topologyFcn,'hextop')
    z = sqrt(0.75);
    shapex = [-1 0 1 1 0 -1]*0.5;
    shapey = [1 2 1 -1 -2 -1]*(z/3);
    dx = 1;
    dy = sqrt(0.75);
  end

  if (plotData.numInputs ~= numInputs) || (plotData.numNeurons ~= numNeurons) ...
      || ~strcmp(plotData.topologyFcn,topologyFcn)
    set(fig,'nextplot','replace');
    
    plotData.numInputs = numInputs;
    plotData.numNeurons = numNeurons;
    plotData.topologyFcn = topologyFcn;

    pos = net.layers{1}.positions;
    dim = net.layers{1}.dimensions;
    numDimensions = length(dim);
    if (numDimensions == 1)
      dim1 = dim(1);
      dim2 = 1;
      pos = [pos; zeros(1,size(pos,2))];
    elseif (numDimensions > 2)
      pos = pos(1:2,:);
      dim1 = dim(1);
      dim2 = dim(2);
    else
      dim1 = dim(1);
      dim2 = dim(2);
    end

    plotcols = ceil(sqrt(numInputs));
    plotrows = ceil(numInputs/plotcols);

    plotData.patches = cell(numInputs);
    for i=1:plotrows
      for j=1:plotcols
        k = (i-1)*plotcols+j;
        if (k<=numInputs)
          a = subplot(plotrows,plotcols,k);
          cla(a);
          set(a,...
            'dataaspectratio',[1 1 1], ...
            'box','on',...
            'color',[1 1 1]*0.5)
          hold on

          plotData.patches{k} = zeros(1,numNeurons);
          for ii=1:numNeurons
            z = fill(pos(1,ii)+shapex,pos(2,ii)+shapey,[1 1 1]);
            set(z,'EdgeColor','none');
            plotData.patches{k}(ii) = z;
          end

          set(a,'xlim',[-1 (dim1-0.5)*dx + 1]);
          set(a,'ylim',[-1 (dim2-0.5)*dy + 0.5]);
          title(a,['Weights from Input ' num2str(k)]);
        end
      end
    end

    screenSize = get(0,'ScreenSize');
    screenSize = screenSize(3:4);
    windowSize = 700 * [1 (plotrows/plotcols)];
    pos = [(screenSize-windowSize)/2 windowSize];
    set(fig,'position',pos);
  end

  iw = net.IW{1,1};
  %min_neg = min(0,min(iw,[],1));
  %max_pos = max(0,max(iw,[],1));
  mn = min(iw,[],1);
  mx = max(iw,[],1);
  rng = mx-mn;
  for i=1:numInputs
    for j=1:numNeurons
      level = net.IW{1,1}(j,i);
      %if level<0, level = -level/min_neg(i); end
      %if level>0, level = level/max_pos(i); end
      %red = min(1,max(0,level)*2); % positive
      %blue = -max(-1,min(0,level)*2); % negative
      %green = max(0,abs(level)*2-1); % very positive/negative
      level = (level-mn(i))/rng(i);
      red = min(1,level*2);
      green = max(0,level*2-1);
      blue = 0;
      c = [red green blue];
      set(plotData.patches{i}(j),'FaceColor',c);
    end
  end
end

