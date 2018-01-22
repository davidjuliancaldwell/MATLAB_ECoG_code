function out1 = newrb(varargin)
%NEWRB Design a radial basis network.
%
%  Radial basis networks can be used to approximate functions.  <a href="matlab:doc newrb">newrb</a>
%  adds neurons to the hidden layer of a radial basis network until it
%  meets the specified mean squared error goal.
%
%  <a href="matlab:doc newrb">newrb</a>(X,T,GOAL,SPREAD,MN,DF) takes these arguments,
%    X      - RxQ matrix of Q input vectors.
%    T      - SxQ matrix of Q target class vectors.
%    GOAL   - Mean squared error goal, default = 0.0.
%    SPREAD - Spread of radial basis functions, default = 1.0.
%    MN     - Maximum number of neurons, default is Q.
%    DF     - Number of neurons to add between displays, default = 25.
%  and returns a new radial basis network.
%
%  The larger that SPREAD is the smoother the function approximation
%  will be.  Too large a spread means a lot of neurons will be
%  required to fit a fast changing function.  Too small a spread
%  means many neurons will be required to fit a smooth function,
%  and the network may not generalize well.  Call NEWRB with
%  different spreads to find the best value for a given problem.
%
%  Here we design a radial basis network given inputs X and targets T.
%
%    X = [1 2 3];
%    T = [2.0 4.1 5.9];
%    net = <a href="matlab:doc newrb">newrb</a>(X,T);
%    Y = net(X)
%
%  See also SIM, NEWRBE, NEWGRNN, NEWPNN.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.6.13 $ $Date: 2011/08/29 20:34:05 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Network Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin > 0) && ischar(varargin{1}) ...
      && ~strcmpi(varargin{1},'hardlim') && ~strcmpi(varargin{1},'hardlims')
    code = varargin{1};
    switch code
      case 'info',
        out1 = INFO;
      case 'check_param'
        err = check_param(varargin{2});
        if ~isempty(err), nnerr.throw('Args',err); end
        out1 = err;
      case 'create'
        if nargin < 2, error(message('nnet:Args:NotEnough')); end
        param = varargin{2};
        err = nntest.param(INFO.parameters,param);
        if ~isempty(err), nnerr.throw('Args',err); end
        out1 = create_network(param);
        out1.name = INFO.name;
      otherwise,
        % Quick info field access
        try
          out1 = eval(['INFO.' code]);
        catch %#ok<CTCH>
          nnerr.throw(['Unrecognized argument: ''' code ''''])
        end
    end
  else
    [args,param] = nnparam.extract_param(varargin,INFO.defaultParam);
    [param,err] = INFO.overrideStructure(param,args);
    if ~isempty(err), nnerr.throw('Args',err,'Parameters'); end
    net = create_network(param);
    net.name = INFO.name;
    out1 = init(net);
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnNetwork(mfilename,'Radial Basis Network',fcnversion, ...
    [ ...
    nnetParamInfo('inputs','Input Data','nntype.data',{0},...
    'Input data.'), ...
    nnetParamInfo('targets','Target Data','nntype.data',{0},...
    'Target output data.'), ...
    nnetParamInfo('goal','Performance Goal','nntype.pos_scalar',0,...
    'Performance goal.'), ...
    nnetParamInfo('spread','Radial basis spread','nntype.strict_pos_scalar',1,...
    'Distance from radial basis center to 0.5 output.'), ...
    nnetParamInfo('maxNeurons','Maximum number of neurons','nntype.pos_int_inf_scalar',inf,... % TODO - type
    'Maximum number of neurons to add to network.'), ...
    nnetParamInfo('displayFreq','Display Frequency','nntype.strict_pos_int_scalar',1,...
    'Number of added neurons between displaying progress at command line.'), ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = create_network(param)

  % Data
  p = param.inputs;
  t = param.targets;
  if iscell(p), p = cell2mat(p); end
  if iscell(t), t = cell2mat(t); end

  % Max Neurons
  Q = size(p,2);
  mn = param.maxNeurons;
  if (mn > Q), mn = Q; end


  % Dimensions
  R = size(p,1);
  S2 = size(t,1);

  % Architecture
  net = network(1,2,[1;1],[1; 0],[0 0;1 0],[0 1]);

  % Simulation
  net.inputs{1}.size = R;
  net.layers{1}.size = 0;
  net.inputWeights{1,1}.weightFcn = 'dist';
  net.layers{1}.netInputFcn = 'netprod';
  net.layers{1}.transferFcn = 'radbas';
  net.layers{2}.size = S2;
  net.outputs{2}.exampleOutput = t;

  % Performance
  net.performFcn = 'mse';

  % Design Weights and Bias Values
  warn1 = warning('off','MATLAB:rankDeficientMatrix');
  warn2 = warning('off','MATLAB:nearlySingularMatrix');
  [w1,b1,w2,b2,tr] = designrb(p,t,param.goal,param.spread,mn,param.displayFreq);
  warning(warn1.state,warn1.identifier);
  warning(warn2.state,warn2.identifier);

  net.layers{1}.size = length(b1);
  net.b{1} = b1;
  net.iw{1,1} = w1;
  net.b{2} = b2;
  net.lw{2,1} = w2;
end

%======================================================
function [w1,b1,w2,b2,tr] = designrb(p,t,eg,sp,mn,df)

  [r,q] = size(p);
  [s2,q] = size(t);
  b = sqrt(-log(.5))/sp;

  % RADIAL BASIS LAYER OUTPUTS
  P = radbas(dist(p',p)*b);
  PP = sum(P.*P)';
  d = t';
  dd = sum(d.*d)';

  % CALCULATE "ERRORS" ASSOCIATED WITH VECTORS
  e = ((P' * d)' .^ 2) ./ (dd * PP');

  % PICK VECTOR WITH MOST "ERROR"
  pick = findLargeColumn(e);
  used = [];
  left = 1:q;
  W = P(:,pick);
  P(:,pick) = []; PP(pick,:) = [];
  e(:,pick) = [];
  used = [used left(pick)];
  left(pick) = [];

  % CALCULATE ACTUAL ERROR
  w1 = p(:,used)';
  a1 = radbas(dist(w1,p)*b);
  [w2,b2] = solvelin2(a1,t);
  a2 = w2*a1 + b2*ones(1,q);
  MSE = mse(t-a2);

  % Start
  tr = nntraining.newtr(mn,'perf');
  tr.perf(1) = mse(t-repmat(mean(t,2),1,q));
  tr.perf(2) = MSE;
  if isfinite(df)
    fprintf('NEWRB, neurons = 0, MSE = %g\n',tr.perf(1));
  end
  flag_stop = 0;

  iterations = min(mn,q);
  for k = 2:iterations

    % CALCULATE "ERRORS" ASSOCIATED WITH VECTORS
    wj = W(:,k-1);
    a = wj' * P / (wj'*wj);
    P = P - wj * a;
    PP = sum(P.*P)';
    e = ((P' * d)' .^ 2) ./ (dd * PP');

    % PICK VECTOR WITH MOST "ERROR"
    pick = findLargeColumn(e);
    W = [W, P(:,pick)];
    P(:,pick) = []; PP(pick,:) = [];
    e(:,pick) = [];
    used = [used left(pick)];
    left(pick) = [];

    % CALCULATE ACTUAL ERROR
    w1 = p(:,used)';
    a1 = radbas(dist(w1,p)*b);
    [w2,b2] = solvelin2(a1,t);
    a2 = w2*a1 + b2*ones(1,q);
    MSE = mse(t-a2);

    % PROGRESS
    tr.perf(k+1) = MSE;

    % DISPLAY
    if isfinite(df) & (~rem(k,df))
      fprintf('NEWRB, neurons = %g, MSE = %g\n',k,MSE);
      flag_stop=plotperfrb(tr,eg,'NEWRB',k);
    end

    % CHECK ERROR
    if (MSE < eg), break, end
    if (flag_stop), break, end

  end

  [S1,R] = size(w1);
  b1 = ones(S1,1)*b;

  % Finish
  if isempty(k), k = 1; end
  tr = nntraining.cliptr(tr,k);
end

%======================================================

function i = findLargeColumn(m)
  replace = find(isnan(m));
  m(replace) = zeros(size(replace));
  m = sum(m .^ 2,1);
  i = find(m == max(m));
  i = i(1);
end

%======================================================

function [w,b] = solvelin2(p,t)
  if nargout <= 1
    w= t/p;
  else
    [pr,pc] = size(p);
    x = t/[p; ones(1,pc)];
    w = x(:,1:pr);
    b = x(:,pr+1);
  end
end

%======================================================

function stop=plotperfrb(tr,goal,name,epoch)
  % Error check: must be at least one argument
  if nargin < 1, error(message('nnet:Args:NotEnough')); end

  % NNT 5.1 Backward compatibility
  if (nargin == 1) && ischar(tr)
    stop = 1;
    return
  end

  % Defaults
  if nargin < 2, goal = NaN; end
  if nargin < 3, name = 'Training Record'; end
  if nargin < 4, epoch = length(tr.epoch)-1; end

  % Special case 2: Delete plot if zero epochs
  if (epoch == 0) || isnan(tr.perf(1))
    fig = find_existing_figure;
    if (fig), delete(fig); end
    if (nargout) stop = 0; end
    return
  end

  % Special case 3: No plot if performance is NaN
  if (epoch == 0) || isnan(tr.perf(1))
    if (nargout) stop = 0; end
    return
  end

  % GET FIGURE AND USER DATA
  % ========================

  % Get existing/new figure
  fig2 = find_existing_figure;
  if (fig2 == 0), fig2 = new_figure(name); end
  figure(fig2);

  % Get existing/new userdata
  ud=get(fig2,'userdata');
  if isempty(ud)
    createNewPlot(fig2);
    ud = get(fig2,'userdata');
  end

  % UPDATE PLOTTING DATA
  % ====================

  % Epoch indices and initial y-limits
  ind = 1:(epoch+1);
  ymax=1e-20;
  ymin=1e20;

  % Update validation-performance plot and y-limits (if required)
  if isfield(tr,'vperf')
    plotValidation = ~isnan(tr.vperf(1));
  else
    plotValidation = 0;
  end
  if plotValidation
    set(ud.TrainLine(3),...
        'Xdata',tr.epoch(ind),...
        'Ydata',tr.vperf(ind),...
        'linewidth',2,'color','g');
    ymax=(max([ymax tr.vperf(ind)]));   
    ymin=(min([ymin tr.vperf(ind)]));   
  end

  % Update test-performance plot and y-limits (if required)
  if isfield(tr,'tperf')
    plotTest = ~isnan(tr.tperf(1));
  else
    plotTest = 0;
  end
  if plotTest
    set(ud.TrainLine(2),...
        'Xdata',tr.epoch(ind),...
        'Ydata',tr.tperf(ind),...
        'linewidth',2,'color','r');
    ymax=(max([ymax tr.tperf(ind)]));   
    ymin=(min([ymin tr.tperf(ind)]));   
  end

  % Update performance plot and ylimits
  set(ud.TrainLine(4),...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.perf(ind),...
      'linewidth',2,'color','b');
  ymax=(max([ymax tr.perf(ind)]));   
  ymin=(min([ymin tr.perf(ind)]));

  % Update performance goal plot and y-limits (if required)
  % plot goal only if > 0, or if 0 and ymin is also 0
  plotGoal = isfinite(goal) & ((goal > 0) | (ymin == 0));
  if plotGoal
    set(ud.TrainLine(1),...
        'Xdata',tr.epoch(ind),...
        'Ydata',goal+zeros(1,epoch+1),...
        'linewidth',2,'color','k');
    ymax=(max([ymax goal]));   
    ymin=(min([ymin goal]));
  end

  % Update axis scale and rounded y-limits
  if (ymin > 0)
    yscale = 'log';
    ymax=10^ceil(log10(ymax));
    ymin=10^fix(log10(ymin)-1);
  else
    yscale = 'linear';
    ymax=10^ceil(log10(ymax));
    ymin=0;
  end
  set(ud.TrainAxes,'xlim',[0 epoch],'ylim',[ymin ymax]);
  set(ud.TrainAxes,'yscale',yscale);

  % UPDATE FIGURE TITLE, NAME, AND AXIS LABLES
  % ====================

  % Update figure title
  tstring = sprintf('Performance is %g',tr.perf(epoch+1));
  if isfinite(goal)
    tstring = [tstring ', ' sprintf('Goal is %g',goal)];
  end
  set(ud.TrainTitle,'string',tstring);

  % Update figure name
  if isempty(name)
    set(fig2,'name',['Training with ' upper(tr.trainFcn)],'numbertitle','off');
  end

  % Update axis x-label
  if epoch == 0
     set(ud.TrainXlabel,'string','Zero Epochs');
  elseif epoch == 1
     set(ud.TrainXlabel,'string','One Epoch');
  else
     set(ud.TrainXlabel,'string',[num2str(epoch) ' Epochs']);
  end

  % Update axis y-lable
  set(ud.TrainYlabel,'string','Performance');

  % FINISH
  % ======

  % Make changes now
  drawnow;

  % Return stop flag if required
  if (nargout), stop = 0; end
end

%======================================================

% Find pre-existing figure, if any
function fig = find_existing_figure
  % Initially assume figure does not exist
  fig = 0;
  % Search children of root...
  for child=get(0,'children')'
    % ...for objects whose type is figure...
    if strcmp(get(child,'type'),'figure') 
      % ...whose tag is 'train'
      if strcmp(get(child,'tag'),'train')
         % ...and stop search if found.
         fig = child;
       break
     end
    end
  end
  % Not sure if/why this is necessary
  if length(get(fig,'children')) == 0
    fig = 0;
  end
end

%======================================================

% New figure
function fig = new_figure(name)
  fig = figure(...
      'Units',          'pixel',...
      'Name',           name,...
      'Tag',            'train',...
      'NumberTitle',    'off',...
      'IntegerHandle',  'off',...
      'Toolbar',        'none');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create new plot in figure

function createNewPlot(fig)
  % Delete all children from figure
  z = get(fig,'children');
  for i=1:length(z)
      delete (z(i));
  end

  % Create axis
  ud.TrainAxes     = axes('Parent',fig);
  ud.TrainLine     = plot(0,0,0,0,0,0,0,0,'EraseMode','None','Parent',ud.TrainAxes);
  ud.TrainXlabel   = xlabel('X Axis','Parent',ud.TrainAxes);
  ud.TrainYlabel   = ylabel('Y Axis','Parent',ud.TrainAxes);
  ud.TrainTitle    = get(ud.TrainAxes,'Title');
  set(ud.TrainAxes,'yscale','log');
  ud.XData      = [];
  ud.YData      = [];
  ud.Y2Data     = [];
  set(fig,'UserData',ud,'menubar','none','toolbar','none');

  legend([ud.TrainLine(4) ud.TrainLine(3) ud.TrainLine(2)],'Train','Validation','Test');

  % Bring figure to front
  figure(fig);
end

%======================================================
