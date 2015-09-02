function [] = nn_train_feedback(command,net,varargin)

% Copyright 2007-2012 The MathWorks, Inc.

showWindow = net.trainParam.showWindow;
showCommandLine = net.trainParam.showCommandLine;

% No Java Compatibility
if ~usejava('swing')
  if (showWindow)
    showCommandLine = true;
    showWindow =  false;
  end
end

persistent LAST_TIME;
if isempty(LAST_TIME)
  LAST_TIME = [0 0 0 0 0 0];
end

% NNT 5.1 Backward Compatibility
if isnan(net.trainParam.show)
  showCommandLine = false;
end

switch command
  
  case 'start'
    
    algorithms = {net.divideFcn,net.trainFcn,net.performFcn,net.derivFcn};
    [status] = deal(varargin{:});
    if (showWindow)
      nntraintool('start',net,algorithms,status);
    end
    if (showCommandLine)
      disp(' ')
      disp(['Training with ' upper(net.trainFcn) '.']);
    end
    
  case 'update'
    
    if numel(varargin) == 6
      [data,calcLib,calcNet,tr,status,statusValues] = deal(varargin{:});
    else % numel(varargin) == 4
      [status,tr,data,statusValues] = deal(varargin{:});
      calcLib = [];
      calcNet = [];
    end
    
    doStart = (tr.num_epochs == 0);
    doStop = ~isempty(tr.stop);
    
    % Update NN Training Tool Window
    if (showWindow)
      nntraintool('clear_stops')
      new_time = clock;
      if (doStart || doStop || (etime(new_time,LAST_TIME) > 0.1))
        nntraintool('update',net,data,calcLib,calcNet,tr,statusValues);
        LAST_TIME = new_time;
      end
    end
    
    % Update Command Line
    if (showCommandLine)
      if doStart || doStop || (rem(tr.num_epochs,net.trainParam.show)==0)
        numStatus = length(status);
        s = cell(1,numStatus*2-1);
        for i=1:length(status)
          s{i*2-1} = train_status_str(status(i),statusValues(i));
          if (i < numStatus), s{i*2} = ', '; end
        end
        disp([s{:}])
        if doStop
          disp(['Training with ' upper(net.trainFcn) ' completed: ' tr.stop])
          disp(' ');
        end
      end
    end
end

%%
function str = train_status_str(status,value)

if ~isfinite(status.max)
  str = [status.name ' ' num2str(value)];
else
  str = [status.name ' ' num2str(value) '/' num2str(status.max)];
end
