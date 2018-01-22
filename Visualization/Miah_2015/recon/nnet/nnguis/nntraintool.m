function [result,result2] = nntraintool(command,varargin)
%NNTRAINTOOL Neural network training tool
%
%  Syntax
%
%    nntraintool
%    nntraintool('close')
%
%  Description
%
%    NNTRAINTOOL opens the training window GUI. This is launched
%    automatically when TRAIN is called.
%
%    To disable the training window set the following network training
%    property.
%
%      net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>.<a href="matlab:doc nnparam.showWindow">showWindow</a> = false;
%
%    To enable command line training instead.
%
%      net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>.<a href="matlab:doc nnparam.showCommandLine">showCommandLine</a> = true;
%
%    NNTRAINTOOL('close') closes the window.

% Copyright 2007-2012 The MathWorks, Inc.

if ~usejava('swing')
  if (nargin == 1) && strcmp(command,'check')
    result = false;
    result2 = false;
    return
  else
    error(message('nnet:Java:NotAvailable'));
  end
end

if nargin == 0, command = 'select'; end

if nargout > 0, result = []; end
if nargout > 1, result2 = []; end

persistent net;
persistent data;
persistent tr;

persistent trainTool;
if isempty(trainTool)
  %mlock
  trainTool = nnjava.tools('nntraintool');
end

switch command
  
  case {'handle','tool'}
    result = trainTool;
  
  case 'ignore'
  
  case 'show'
    if usejava('swing')
      javaMethodEDT('setVisible',trainTool,true);
      drawnow
    end
    
  case {'hide','close'}
    if usejava('swing')
      trainTool.setVisible(false);
      drawnow
    end
    
  case 'select'
    if usejava('swing')
      trainTool.setVisible(true);
      toFront(trainTool);
      if (nargout > 0), result = trainTool; end
      drawnow
      nngui.publish_java_window(trainTool);
    end
  
  case 'set'
    [net,tr,data] = varargin{:};
    
  case 'get'
    result = {net tr data};
    
  case 'clear_stops'
    if usejava('swing')
      trainTool.clearStops;
    end
    
  case 'start'
    if usejava('swing')
      [net,algorithmNames,status] = varargin{:};
      start(trainTool,net,algorithmNames,status);
    end
    
  case 'check'
    if usejava('swing')
      result = trainTool.isStopped;
      result2 = trainTool.isCancelled;
    else
      result = false;
      result2 = false;
    end
    
  case 'update'
    if usejava('swing')
      
      % Arguments
      [net,data,calcLib,calcNet,tr,statusValues] = varargin{:};      
      
      % Update Status
      trainTool.updateStatus(doubleArray2JavaArray(statusValues));
      
      % Refresh Plots
      epoch = tr.num_epochs;
      plotDelay = trainTool.getPlotDelay;
      refresh = ((~rem(epoch,plotDelay) || ~isempty(tr.stop)));
      if refresh
        if ~isempty(calcLib)
          wb = calcLib.getwb(calcNet);
          net = setwb(net,wb);
        end
        refresh_open_plots(trainTool,net,data,tr);
      end
      if ~isempty(tr.stop)
        done(trainTool,tr.stop);
      end
    end
    
  case 'plot'
    if ~isempty(net)
      plotFcn = varargin{1};
      i = nnstring.first_match(plotFcn,net.plotFcns);
      plotParams = net.plotParams{i};
      fig = feval(plotFcn,'training',net,tr,data,plotParams);
      figure(fig);
    end
    
  otherwise, error(message('nnet:Args:Unrec'));
end

%%
function start(trainTool,net,algorithmNames,status)

diagram = nnjava.tools('diagram',net);
    
numAlgorithms = length(algorithmNames);
emptyNames = false(1,numAlgorithms);
for i=1:numAlgorithms, emptyNames(i) = isempty(algorithmNames{i}); end
algorithmNames = algorithmNames(~emptyNames);
numAlgorithms = length(algorithmNames);

algorithmTypes = cell(1,length(algorithmNames));
algorithmTitles = cell(1,length(algorithmNames));
for i=1:numAlgorithms
 info = feval(algorithmNames{i},'info');
 algorithmTypes{i} = strrep(info.typeName,' Function','');
 algorithmTitles{i} = info.name;
end

plotFcns = net.plotFcns;
numPlots = length(plotFcns);
plotNames = cell(1,numPlots);
for i=1:numPlots
  plotNames{i} = feval(plotFcns{i},'name');
end

x1 = diagram;
x2 = stringCellArray2JavaArray(algorithmTypes);
x3 = stringCellArray2JavaArray(algorithmNames);
x4 = stringCellArray2JavaArray(algorithmTitles);
x5 = stringCellArray2JavaArray({status(:).name});
x6 = stringCellArray2JavaArray({status(:).units});
x7 = stringCellArray2JavaArray({status(:).scale});
x8 = stringCellArray2JavaArray({status(:).form});
x9 = doubleArray2JavaArray([status(:).min]);
x10 = doubleArray2JavaArray([status(:).max]);
x11 = doubleArray2JavaArray([status(:).value]);
x12 = stringCellArray2JavaArray(plotFcns);
x13 = stringCellArray2JavaArray(plotNames);

trainTool.launch(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13);
drawnow

%%
function refresh_open_plots(trainTool,net,data,tr)

% Ensure MATLAB Object NN has same WB as calculation network      
for i=1:length(net.plotFcns)
  plotFcn = net.plotFcns{i};
  userSelected = getPlotFlag(trainTool,i-1);
  fig = [];
  try
    fig = find_tagged_figure(['TRAINING_' upper(plotFcn)]);
  catch %#ok<CTCH>
    % This try-catch clause shields training from plotting failures
  end
  if userSelected || (~isempty(fig) && ishandle(fig))
    plotParam = net.plotParams{i};
    try
      fig = feval(plotFcn,'training',net,tr,data,plotParam);
    catch %#ok<CTCH>
      % This try-catch clause shields training from plotting failures
      if ~isempty(fig) && ishandle(fig)
        try
          close(fig)
        catch %#ok<CTCH>
          % This try-catch clause shields training from plotting failures
          % If the figure was found with the 'TRAINING_' tag, but
          % cannot be updated, closing it may correct the problem and
          % will at least avoid repeated errors.
        end
      end
    end
  end
  if (userSelected && ishandle(fig))
    try
      figure(fig);
    catch %#ok<CTCH>
      % This try-catch clause shields training from plotting failures
    end
  end
end

%%
function fig = find_tagged_figure(tag)

for object = get(0,'children')'
  if strcmp(get(object,'type'),'figure') 
    if strcmp(get(object,'tag'),tag)
     fig = object;
     return
   end
  end
end
fig = [];

%%
function y = stringCellArray2JavaArray(x)

count = length(x);
y = nnjava.tools('stringarray',count);
for i=1:count, y(i) = nnjava.tools('string',x{i}); end

%%
function y = doubleArray2JavaArray(x)

count = length(x);
y = nnjava.tools('doublearray',count);
for i=1:count, y(i) = nnjava.tools('double',x(i)); end
