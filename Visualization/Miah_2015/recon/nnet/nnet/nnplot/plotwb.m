function out1 = plotwb(varargin)
%PLOTWB Plot Hinton diagrams of weight and bias values.
%
% <a href="matlab:doc plotwb">plotwb</a>(NET) takes a network and plots its weight and bias values as
% squares whose sizes indicate their magnitude and color their sign.
%
% <a href="matlab:doc plotwb">plotwb</a>(...,'toLayers',toLayers,'fromInputs',fromInputs,'fromLayers',
%   fromLayers,'fromBiases',fromBiases) takes several optional parameters
%   overriding the default weight/bias connections to show in terms of
%   layers connections go to (1:net.numLayers), connections from inputs
%   (1:net.numInputs), connections from layers (1:net.numLayers), and
%   connections from biases (1:net.numBiases).
%
% <a href="matlab:doc plotwb">plotwb</a>(...,'root',root) is another optional parameter which overrides
%   the exponent linking weight magnitude to its square's radius.  The
%   root is normally 2, but larger values make it easier to see
%   smaller weights.
%
% <a href="matlab:doc plotwb">plotwb</a>(IW,LW,B) takes any one, two or three arguments, a cell array
% of input weights, a cell array of layer weights, and a cell column of
% of biases (each cell array must have the same number of rows) and
% plots the weight and bias values contained in the cells.
%
% Here a cascade-forward network is configured for particular data and
% its weights and biases are plotted in several ways.
%
%   [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%   net = <a href="matlab:doc cascadeforwardnet">cascadeforwardnet</a>([15 5]);
%   net = <a href="matlab:doc configure">configure</a>(net,x,t);
%   <a href="matlab:doc plotwb">plotwb</a>(net)
%   <a href="matlab:doc plotwb">plotwb</a>(net,'root',3)
%   <a href="matlab:doc plotwb">plotwb</a>(net,'root',4)
%   <a href="matlab:doc plotwb">plotwb</a>(net,'toLayers',2)
%   <a href="matlab:doc plotwb">plotwb</a>(net,'fromLayers',1)
%   <a href="matlab:doc plotwb">plotwb</a>(net,'toLayers',2,'fromInputs',1)
%   
% See also plotsomplanes.

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
  info = nnfcnPlot(mfilename,'Hinton Weight Bias',7.0,...
    [...
    nnetParamInfo('toLayers','Layer Indices','nntype.index_row',[],...
      'Indices of layers to plot.'),...
    nnetParamInfo('fromInputs','Input Indices','nntype.index_row',[],...
      'Indices of input weights to plot. '), ...
    nnetParamInfo('fromLayers','Source Layer Indices','nntype.index_row',[],...
      'Indices of layer weights to plot. '), ...
    nnetParamInfo('fromBias','Include Bias?','nntype.bool_scalar',0,...
      'Flag indicating whether to plot bias.'), ...
    nnetParamInfo('root','Diameter root','nntype.pos_int_scalar',2,...
      'Square diameters are weight or bias values to 1/root power.'),...
    ]);
end

% TODO - Minimum=NaN, Center=0, Maximum values=NaN
% TODO - Accept series of matrices with same # of rows, last with 1 col.
% TODO - Add NAMES as internal argument?

function args = training_args(net,tr,data)
  args = {net.IW net.LW net.b};
end

function args = standard_args(varargin)
  if nargin < 1
    args = 'Not enough input arguments.';
    return
  end
  if isa(varargin{1},'network')
    net = varargin{1};
    args = {net.iw,net.lw,net.b};
  else
    iw = varargin{1};
    if nntype.matrix_data('isa',iw)
      iw = {iw};
    elseif ~nntype.matrix_data('isa',iw)
      args = 'First argument is not neural data.';
      return
    end
    if nargin >= 2
      lw = varargin{2};
      if nntype.matrix_data('isa',lw)
        lw = {lw};
      elseif ~nntype.matrix_data('isa',lw)
        args = 'Second argument is not neural data.';
        return
      end
    else
      lw = cell(size(iw,1),0);
    end
    if nargin >= 3
      b = varargin{3};
      if nntype.matrix_data('isa',b)
        if size(b,2) > 1
          args = 'Third argument has more than one column.';
          return
        end
        b = {b};
      elseif ~nntype.matrix_data('isa',b)
        args = 'Third argument is not neural data.';
        return
      elseif size(b,2) ~= 1
        args = 'Third argument has more than one column.';
        return
      end
    else
      b = cell(size(iw,1),0);
    end
    args = {iw,lw,b};
  end
end

function plotData = setup_plot(fig)
  PTFS = nnplots.title_font_size;

  plotData.numRows = 0;
  plotData.numCols = 0;
  plotData.numAxisRows = zeros(0,0);
  plotData.numAxisCols = zeros(0,0);
  plotData.squares = cell(0,0);
  plotData.axis = axes;
  set(plotData.axis,'dataaspectratio',[1 1 1],'box','on')
  set(plotData.axis,'ydir','reverse','tickdir','out')
  plotData.axis2 = axes('position',get(plotData.axis,'position'));
  set(plotData.axis2,'dataaspectratio',[1 1 1],'box','on')
  set(plotData.axis2,'xaxislocation','top','yaxislocation','right')
  set(plotData.axis2,'ydir','reverse','tickdir','out')
  set(plotData.axis2,'color','none')
  set(get(plotData.axis2,'xlabel'),'string','From Source: Input, Layer or Bias',...
    'fontweight','bold','fontsize',PTFS);
  set(get(plotData.axis,'xlabel'),'string','Elements within Sources',...
    'fontweight','bold','fontsize',PTFS);
  set(get(plotData.axis,'ylabel'),'string','To Layer',...
    'fontweight','bold','fontsize',PTFS);
  set(get(plotData.axis2,'ylabel'),'string','Neurons within Layers',...
    'fontweight','bold','fontsize',PTFS);
  set(plotData.axis2,'TickLength',[0 0]);
  set(plotData.axis,'TickLength',[0 0]);
end

function fail = unsuitable_to_plot(param,iw,lw,b)
  fail = '';
end

function plotData = update_plot(param,fig,plotData,iw,lw,b)
  allw = [iw lw b];
  numInputs = size(iw,2);
  numLayers = size(iw,1);
  numBias = size(b,2);
      
  if isempty(param.toLayers)
    layerIndices = 1:numLayers;
  else
    layerIndices = intersect(param.toLayers,1:size(allw,1));
  end
  if isempty(param.fromInputs) && ...
    isempty(param.fromLayers) && ~param.fromBias
    weightIndices = 1:size(allw,2);
  else
    iwIndices = intersect(param.fromInputs,1:numInputs);
    lwIndices = intersect(param.fromLayers,1:numLayers);
    bIndex = intersect(param.fromBias,1);
    weightIndices = [iwIndices [lwIndices bIndex+numLayers]+numInputs];
  end
  allw = allw(layerIndices,weightIndices);

  numRows = length(layerIndices);
  numCols = length(weightIndices);
  numAxisRows = zeros(numRows,numCols);
  numAxisCols = zeros(numRows,numCols);
  for i=1:numRows
    for j=1:numCols
      [numAxisRows(i,j),numAxisCols(i,j)] = size(allw{i,j});
    end
  end
  
  numRowRows = zeros(1,numRows);
  for i=1:numRows
    numRowRows(i) = max(numAxisRows(i,:));
  end
  numFigRows = sum(numRowRows);
  numColCols = zeros(1,numCols);
  for i=1:numCols
    numColCols(i) = max(numAxisCols(:,i));
  end
  numFigCols = sum(numColCols);
    
  % Create Axes
  % TODO - Check each weight/bias existence, size and name
  if (numRows ~= plotData.numRows) || (numCols ~= plotData.numCols) ...
    || any(any(plotData.numAxisRows ~= numAxisRows)) ...
    || any(any(plotData.numAxisCols ~= numAxisCols))
    plotData.numRows = numRows;
    plotData.numCols = numCols;
    plotData.numAxisRows = numAxisRows;
    plotData.numAxisCols = numAxisCols;
    
    inputNames = {};
    if numInputs == 1
      inputNames = {'Input'};
    else
      for i=1:numInputs
        inputNames = [inputNames {['Input ' num2str(i)]}];
      end
    end
    layerNames = {};
    if numLayers == 1
      layerNames = {'Layer'};
    else
      for i=1:numLayers
        layerNames = [layerNames {['Layer ' num2str(i)]}];
      end
    end
    biasNames = {};
    if numBias
      biasNames = {'Bias'};
    end
    allNames = [inputNames layerNames biasNames];
    layerNames = layerNames(layerIndices);
    allNames = allNames(weightIndices);
    
    axes(plotData.axis);
    hold on
    cla(plotData.axis);
    cla(plotData.axis2);
    set(plotData.axis,'xlim',[0 max(numFigCols,0.001)]+0.5,'ylim',[0 max(numFigRows,0.001)]+0.5)
    set(plotData.axis2,'xlim',[0 max(numFigCols,0.001)]+0.5,'ylim',[0 max(numFigRows,0.001)]+0.5)
    
    plotData.squares = cell(numFigRows,numFigCols);
    
    y = 0.5;
    for i=1:numRows
      h = numRowRows(i);
      x = 0.5;
      for j=1:numCols
        w = numColCols(j);
        square = zeros(h,w);
        if isempty(allw{i,j})
          xxx = x+[0 1 1 0]*w;
          yyy = y+[0 0 1 1]*h;
          fill(xxx,yyy,[1 1 1]*0.5,'edgecolor',[0 0 0],'lineWidth',2);
        else
          for ii=1:numRowRows(i)
            yy = y + ii-1 + [0 1 1 0];
            for jj=1:numColCols(j)
              xx = x + jj-1 + [0 0 1 1];
              c = rand(1,3);
              square(ii,jj) = fill(xx,yy,c,'edgecolor','none');
            end
          end
          xxx = x+[0 1 1 0 0]*w;
          yyy = y+[0 0 1 1 0]*h;
          plot(xxx,yyy,'color',[0 0 0],'lineWidth',2);
        end
        x = x + w;
        plotData.squares{i,j} = square;
      end
      y = y + h;
    end
    
    ticks1 = [];
    labels1 = {};
    ticks2 = [];
    lables2 = {};
    pos = 0;
    for i=1:numRows
      ni = numRowRows(i);
      if ni >= 1
        ticks1 = [ticks1 pos+(1+ni)/2];
        labels1 = [labels1 layerNames(i)];
      end
      if ni == 1
        ticks2 = [ticks2 (pos+1)];
        lables2 = [lables2 {'1'}];
      elseif ni > 1
        ticks2 = [ticks2 pos+[1 ni]];
        lables2 = [lables2 {'1',num2str(ni)}];
      end
      pos = pos + ni;
    end
    set(plotData.axis,'ytick',ticks1,'yticklabel',labels1);
    set(plotData.axis2,'ytick',ticks2,'yticklabel',lables2);
    ticks1 = [];
    labels1 = {};
    ticks2 = [];
    lables2 = {};
    pos = 0;
    for i=1:numCols
      ni = numColCols(i);
      if ni >= 1
        ticks1 = [ticks1 pos+(1+ni)/2];
        labels1 = [labels1 allNames(i)];
      end
      if ni == 1
        ticks2 = [ticks2 (pos+1)];
        lables2 = [lables2 {'1'}];
      elseif ni > 1
        ticks2 = [ticks2 pos+[1 ni]];
        lables2 = [lables2 {'1',num2str(ni)}];
      end
      pos = pos + ni;
    end
    set(plotData.axis2,'xtick',ticks1,'xticklabel',labels1);
    set(plotData.axis,'xtick',ticks2,'xticklabel',lables2);
    
    screenSize = get(0,'ScreenSize');
    screenSize = screenSize(3:4);
    windowSize = [800 500];
    pos = [(screenSize-windowSize)/2 windowSize];
    set(fig,'position',pos);
  end

  % Update Axes
  maxwb = NaN;
  for i=1:numRows
    for j=1:numCols
      wb = allw{i,j};
      if ~isempty(wb)
        maxwb = max(maxwb,max(max(abs(wb))));
      end
    end
  end
  
  y = 0.5;
  for i=1:numRows
    h = numRowRows(i);
    x = 0.5;
    for j=1:numCols
      w = numColCols(j);
      wb = allw{i,j};
      if ~isempty(wb)
        square = plotData.squares{i,j};
        for ii=1:numRowRows(i)
          for jj=1:numColCols(j)
            percent = wb(ii,jj)/maxwb;
            diameter = abs(percent)^(1/param.root);
            yy = y + ii-1 + [-0.5 0.5 0.5 -0.5]*diameter + 0.5;
            xx = x + jj-1 + [-0.5 -0.5 0.5 0.5]*diameter + 0.5;
            if percent < 0
              ce = [0.5 0 0];
              cf = [1 0.2 0.2];
            else
              ce = [0 0.5 0];
              cf = [0.2 1 0.3];
            end
            set(square(ii,jj),'xdata',xx,'ydata',yy,...
              'facecolor',cf,'edgecolor',ce);
          end
        end
      end
      x = x + w;
    end
    y = y + h;
  end
end

