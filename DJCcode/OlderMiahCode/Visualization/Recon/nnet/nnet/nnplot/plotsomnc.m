function out1 = plotsomnc(varargin)
%PLOTSOMNC Plot Self-organizing map neighbor connections.
%
% <a href="matlab:doc plotsomnc">plotsomnc</a>(net) takes a self-organizing map network and plots shows the
% connections between adjecent neurons.
%
% Here a self-organizing map is plotted:
%
%    net = <a href="matlab:doc selforgmap">selforgmap</a>([8 8]);
%    <a href="matlab:doc plotsomnc">plotsomnc</a>(net);
%
% See also plotsomhits, plotsomnd plotsomplanes, plotsompos, plotsomtop.

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
  info = nnfcnPlot(mfilename,'SOM Neighbor Connections',7.0,[]);
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
    edgex = [-1 0 1 0]*0.5;
    edgey = [0 1 0 -1]*0.5;
  elseif strcmp(topologyFcn,'hextop')
    z = sqrt(0.75)/3;
    shapex = [-1 0 1 1 0 -1]*0.5;
    shapey = [1 2 1 -1 -2 -1]*z;
    dx = 1;
    dy = sqrt(0.75);
    edgex = [-1 0 1 0]*0.5;
    edgey = [0 1 0 -1]*z;
  end
  shapex = shapex*0.3;
  shapey = shapey*0.3;

  pos = net.layers{1}.positions;
  dimensions = net.layers{1}.dimensions;
  numDimensions = length(dimensions);
  if (numDimensions == 1)
    dim1 = dim(1);
    dim2 = 1;
    pos = [pos; zeros(1,size(pos,2))];
  elseif (numDimensions > 2)
    pos = pos(1:2,:);
    dim1 = dimensions(1);
    dim2 = dimensions(2);
  else
    dim1 = dimensions(1);
    dim2 = dimensions(2);
  end

  if (plotData.numInputs ~= numInputs) || any(plotData.dimensions ~= dimensions) ...
      || ~strcmp(plotData.topologyFcn,topologyFcn)
    set(fig,'nextplot','replace');
    plotData.numInputs = numInputs;
    plotData.dimensions = dimensions;
    plotData.topologyFcn = topologyFcn;
    a = plotData.axis;
    cla(a)
    set(a,...
      'dataaspectratio',[1 1 1],...
      'box','on',...
      'color',[1 1 1]*0.5)
    hold on

    % Setup edges
    plotData.neighbors = sparse(tril(net.layers{1}.distances <= 1.001) - eye(numNeurons));
    plotData.numEdges = sum(sum(plotData.neighbors));
    plotData.patches = zeros(1,plotData.numEdges);
    plotData.text = zeros(1,plotData.numEdges);
    k = 1;
    for i=1:numNeurons
      for j=find(plotData.neighbors(i,:))
        pdiff = pos(:,j)-pos(:,i);
        angle = atan2(pdiff(2),pdiff(1));
        [ex,ey] = rotate_xy(edgex,edgey,angle);
        edgePos = (pos(:,i)+pos(:,j))*0.5;
        p1 = (2*pos(:,i) + pos(:,j))./3;
        p2 = (pos(:,i) + 2*pos(:,j))./3;
        plotData.patches(k) = fill(edgePos(1)+ex,edgePos(2)+ey,[1 1 1],...
          'FaceColor',[1 1 1],...
          'EdgeColor',[1 1 1]*0.5);
        plot([p1(1) p2(1)],[p1(2) p2(2)],'-','color',[1 0 0]);
        k = k + 1;
      end
    end

    % Setup neurons
    for i=1:numNeurons
      fill(pos(1,i)+shapex,pos(2,i)+shapey,[1 1 1], ...
        'FaceColor',[0.4 0.4 0.6], ...
        'EdgeColor',[0.4 0.4 0.6]*0.5)
    end
    set(a,'xlim',[-1 (dim1-0.5)*dx + 1]);
    set(a,'ylim',[-1 (dim2-0.5)*dy + 0.5]);
    title(a,'SOM Neighbor Connections');
  end
end

function [x2,y2] = rotate_xy(x1,y1,angle)
  [a,r] = cart2pol(x1,y1);
  a = a + angle;
  [x2,y2] = pol2cart(a,r);
end
