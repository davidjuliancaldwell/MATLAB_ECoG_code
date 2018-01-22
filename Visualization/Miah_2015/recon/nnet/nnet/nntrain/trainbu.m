function [out1,out2] = trainbu(varargin)
%TRAINBU Unsupervised batch training with weight & bias learning rules.
%
%  <a href="matlab:doc trainbu">trainbu</a> trains a network with unsupervised weight and bias learning
%  rules with batch updates. The weights and biases are updated at the end
%  of an entire pass through the input data.
%
%  [NET,TR] = <a href="matlab:doc trainbu">trainbu</a>(NET,X) takes a network NET, input data X
%  and returns the network after training it, and training record TR.
%  
%  [NET,TR] = <a href="matlab:doc trainbu">trainbu</a>(NET,X,{},Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  Training occurs according to training parameters, with default values.
%  Any or all of these can be overridden with parameter name/value argument
%  pairs appended to the input argument list, or by appending a structure
%  argument with fields having one or more of these names.
%    epochs = 100, Maximum number of epochs to train
%    show = 25, Epochs between displays
%    showCommandLine = false, generate command line output
%    showWindow = true, show training GUI
%    time = inf,  Maximum time to train in seconds
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'trainbu';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also NEWSOM, TRAIN.

% Copyright 2007-2012 The MathWorks, Inc.
% $Revision: 1.1.10.8 $  $Date: 2012/04/20 19:14:06 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Training Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  nnassert.minargs(nargin,1);
  in1 = varargin{1};
  if ischar(in1)
    switch (in1)
      case 'info'
        out1 = INFO;
      case 'apply'
        [out1,out2] = train_network(varargin{2:end});
      case 'formatNet'
        out1 = formatNet(varargin{2});
      case 'check_param'
        param = varargin{2};
        err = nntest.param(INFO.parameters,param);
        if isempty(err)
          err = check_param(param);
        end
        if nargout > 0
          out1 = err;
        elseif ~isempty(err)
          nnerr.throw('Type',err);
        end
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    net = varargin{1};
    oldTrainFcn = net.trainFcn;
    oldTrainParam = net.trainParam;
    if ~strcmp(net.trainFcn,mfilename)
      net.trainFcn = mfilename;
      net.trainParam = INFO.defaultParam;
    end
    [out1,out2] = train(net,varargin{2:end});
    net.trainFcn = oldTrainFcn;
    net.trainParam = oldTrainParam;
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  isSupervised = false;
  usesGradient = false;
  usesJacobian = false;
  usesValidation = false;
  supportsCalcModes = false;
  info = nnfcnTraining(mfilename,'Batch Weight/Bias Rules',8.0,...
    isSupervised,usesGradient,usesJacobian,usesValidation,supportsCalcModes,...
    [ ...
    nnetParamInfo('showWindow','Show Training Window Feedback','nntype.bool_scalar',true,...
    'Display training window during training.'), ...
    nnetParamInfo('showCommandLine','Show Command Line Feedback','nntype.bool_scalar',false,...
    'Generate command line output during training.') ...
    nnetParamInfo('show','Command Line Frequency','nntype.strict_pos_int_inf_scalar',25,...
    'Frequency to update command line.'), ...
    ...
    nnetParamInfo('epochs','Maximum Epochs','nntype.pos_scalar',1000,...
    'Maximum number of training iterations before training is stopped.') ...
    nnetParamInfo('time','Maximum Training Time','nntype.pos_inf_scalar',inf,...
    'Maximum time in seconds before training is stopped.') ...
    ], ...
    []);
end

function err = check_param(param)
  err = '';
end

function net = formatNet(net)
end

function [net,tr] = train_network(net,tr,data,fcns,param)

  %% setup
  numLayers = net.numLayers;
  numInputs = net.numInputs;
  numLayerDelays = net.numLayerDelays;
  layer2output = num2cell(cumsum(net.outputConnect));
  layer2output(~net.outputConnect) = {[]};
  
  % Signals
  BP = ones(1,data.Q);
  IWLS = cell(numLayers,numInputs);
  LWLS = cell(numLayers,numLayers);
  BLS = cell(numLayers,1);

  %% Initialize
  startTime = clock;
  original_net = net;

  %% Training Record
  tr.best_epoch = 0;
  tr.goal = NaN;
  tr.states = {'epoch','time'};

  %% Status
  status = ...
    [ ...
    nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
    nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
    ];
  nn_train_feedback('start',net,status);

  %% Train
  for epoch=0:param.epochs

    % Simulation
    data = nn7.y_all(net,data,fcns);
    
    % Stopping Criteria
    current_time = etime(clock,startTime);
    [userStop,userCancel] = nntraintool('check');
    if userStop, tr.stop = 'User stop.';
    elseif userCancel, tr.stop = 'User cancel.'; net = original_net;
    elseif (epoch == param.epochs), tr.stop = 'Maximum epoch reached.';
    elseif (current_time > param.time), tr.stop = 'Maximum time elapsed.';
    end

    % Training record & feedback
    tr = nntraining.tr_update(tr,[epoch current_time]);
    nn_train_feedback('update',net,status,tr,data,[epoch,current_time]);
    
    % Stop
    if ~isempty(tr.stop), break, end

    % Update with Weight and Bias Learning Functions
    for ts=1:data.TS
      for i=1:numLayers
        
        % Update Input Weight Values
        for j=find(net.inputConnect(i,:))
          fcn = fcns.inputWeights(i,j).learn;
          if fcn.exist
            Pd = nntraining.pd(net,data.Q,data.Pc,data.Pd,i,j,ts);
            [dw,IWLS{i,j}] = fcn.apply(net.IW{i,j}, ...
              Pd,data.Zi{i,j},data.N{i},data.Ac{i,ts+numLayerDelays},[],[],[],...
                [],net.layers{i}.distances,fcn.param,IWLS{i,j});
            net.IW{i,j} = net.IW{i,j} + dw;
          end
        end

        % Update Layer Weight Values
        for j=find(net.layerConnect(i,:))
          fcn = fcns.layerWeights(i,j).learn;
          if fcn.exist
            Ad = cell2mat(data.Ac(j,ts+numLayerDelays-net.layerWeights{i,j}.delays)');
            [dw,LWLS{i,j}] = fcn.apply(net.LW{i,j}, ...
              Ad,data.Zl{i,j},data.N{i},data.Ac{i,ts+numLayerDelays},data.Tl{i,ts},[],[],...
              [],net.layers{i}.distances,fcn.param,LWLS{i,j});
            net.LW{i,j} = net.LW{i,j} + dw;
          end
        end

        % Update Bias Values
        if net.biasConnect(i)
          fcn = fcns.bias(i).learn;
          if fcn.exist
            [db,BLS{i}] = fcn.apply(net.b{i}, ...
              BP,data.Zb{i},data.N{i},data.Ac{i,ts+numLayerDelays},[],[],[],...
              [],net.layers{i}.distances,fcn.param,BLS{i});
            net.b{i} = net.b{i} + db;
          end
        end
      end
    end
  end

  % Finish
  tr.best_epoch = param.epochs;
  tr = nntraining.tr_clip(tr);
end


