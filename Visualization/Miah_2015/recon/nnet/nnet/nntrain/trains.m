function [out1,out2] = trains(varargin)
%TRAINS Sequential order weight/bias training.
%
%  <a href="matlab:doc trains">trains</a> trains a network with weight and bias learning rules with
%  incremental updates after each presentation of an input.  Inputs
%  are presented in cyclic order.
%
%  [NET,TR] = <a href="matlab:doc trains">trains</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%  
%  [NET,TR] = <a href="matlab:doc trains">trains</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  Training occurs according to training parameters, with default values.
%  Any or all of these can be overridden with parameter name/value argument
%  pairs appended to the input argument list, or by appending a structure
%  argument with fields having one or more of these names.
%    show     25  Epochs between displays
%    showCommandLine false, generate command line output
%    showWindow true, show training GUI
%    epochs  100  Maximum number of epochs to train
%    goal      0  Performance goal
%    max_fail  5  Maximum validation failures
%    time    inf  Maximum time to train in seconds
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'trains';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also NEWP, NEWLIN, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.15 $  $Date: 2012/04/20 19:14:21 $

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
  isSupervised = true;
  usesGradient = true;
  usesJacobian = false;
  usesValidation = false;
  supportsCalcModes = false;
  info = nnfcnTraining(mfilename,'Sequential Weight/Bias Rule',8.0,...
    isSupervised,usesGradient,usesJacobian,usesValidation,supportsCalcModes,...
    [ ...
    nnetParamInfo('showWindow','Show Training Window Feedback','nntype.bool_scalar',true,...
    'Display training window during training.'), ...
    nnetParamInfo('showCommandLine','Show Command Line Feedback','nntype.bool_scalar',false,...
    'Generate command line output during training.') ...
    nnetParamInfo('show','Command Line Frequency','nntype.strict_pos_int_inf_scalar',25,...
    'Frequency to update command line.'), ...
    ...
    nnetParamInfo('epochs','Maximum Epochs','nntype.pos_int_scalar',1000,...
    'Maximum number of training iterations before training is stopped.') ...
    nnetParamInfo('time','Maximum Training Time','nntype.pos_inf_scalar',inf,...
    'Maximum time in seconds before training is stopped.') ...
    ...
    nnetParamInfo('goal','Performance Goal','nntype.pos_scalar',0,...
    'Performance goal.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.strict_pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ], ...
    []);
end

function err = check_param(param)
  err = '';
end

function net = formatNet(net)
  if isempty(net.performFcn)
    warning('nnet:trainc:Performance',nnwarn_empty_performfcn_corrected);
    net.performFcn = 'mse';
  end
end

function [net,tr] = train_network(net,tr,data,fcns,param)

  % Checks
  
  % Initialize
  needGradient = nn.needsGradient(net);
  startTime = clock;
  original_net = net;
  [perf,vperf,tperf] = nn7.trainValTestPerfs(net,data,fcns);
  BP = 1;
  IWLS = cell(net.numLayers,net.numInputs);
  LWLS = cell(net.numLayers,net.numLayers);
  BLS = cell(net.numLayers,1);
  TS = data.TS;
  Ac = [data.Ai cell(net.numLayers,TS)];
  AiInd = 0:(net.numLayerDelays-1);
  layer2output = num2cell(cumsum(net.outputConnect));
  layer2output(~net.outputConnect) = {[]};

  % Training Record
  tr.best_epoch = 0;
  tr.goal = param.goal;
  tr.states = {'epoch','time','perf','vperf','tperf'};

  % Status
  status = ...
    [ ...
    nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
    nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
    nntraining.status('Performance','','log','continuous',perf,param.goal,perf) ...
    ];
  nn_train_feedback('start',net,status);

  % Train
  for epoch=0:param.epochs

    % Stopping Criteria
    current_time = etime(clock,startTime);
    [userStop,userCancel] = nntraintool('check');
    if userStop, tr.stop = 'User stop.';
    elseif userCancel, tr.stop = 'User cancel.'; net = original_net;
    elseif (perf <= param.goal), tr.stop = 'Performance goal met.';
    elseif (epoch == param.epochs), tr.stop = 'Maximum epoch reached.';
    elseif (current_time >= param.time), tr.stop = 'Maximum time elapsed.';
    end

    % Feedback
    tr = nntraining.tr_update(tr,[epoch current_time perf vperf tperf]);
    nn_train_feedback('update',net,status,tr,data, ...
      [epoch,current_time,perf]);

    % Stop
    if ~isempty(tr.stop), break, end
  
      % Update with Weight and Bias Learning Functions
      for ts=1:data.TS
        
        divData.TS = 1;
        divData.Q = data.Q;
        if isempty(data.Pc)
          divData.Pc = {};
        else
          divData.Pc = data.Pc(:,ts);
        end
        if isempty(data.Pd)
          divData.Pd = {};
        else
          divData.Pd = data.Pd(:,:,ts);
        end
        divData.Ai = Ac(:,ts+AiInd);
        divData.T = data.T(:,ts);
        if size(data.EW,2) > 1
          divData.EW = data.EW(:,ts);
        else
          divData.EW = data.EW;
        end
        
        [~,divData,gB,gIW,gLW,gA] = nn7.perf_sig_grad(net,divData,needGradient,fcns);
        
        for i=1:net.numLayers
          ii = layer2output{i};
          
          % Update Input Weight Values
          for j=find(net.inputConnect(i,:))
            fcn = fcns.inputWeights(i,j).learn;
            if fcn.exist
              Pd = nntraining.pd(net,1,divData.Pc,divData.Pd,i,j,1);
              [dw,IWLS{i,j}] = fcn.apply(net.IW{i,j}, ...
                Pd,divData.Zi{i,j},divData.N{i},divData.Ac{i,1+net.numLayerDelays},...
                [divData.T{ii,1}],[divData.E{ii,1}],gIW{i,j,1},...
                gA{i,1},net.layers{i}.distances,fcn.param,IWLS{i,j});
              net.IW{i,j} = net.IW{i,j} + dw;
            end
          end

          % Update Layer Weight Values
          for j=find(net.layerConnect(i,:))
            fcn = fcns.layerWeights(i,j).learn;
            if fcn.exist
              Ad = cell2mat(divData.Ac(j,1+net.numLayerDelays-net.layerWeights{i,j}.delays)');
              [dw,LWLS{i,j}] = fcn.apply(net.LW{i,j}, ...
                Ad,divData.Zl{i,j},divData.N{i},divData.Ac{i,1+net.numLayerDelays},...
                [divData.T{ii,1}],[divData.E{ii,1}],gLW{i,j,1},...
                gA{i,1},net.layers{i}.distances,fcn.param,LWLS{i,j});
              net.LW{i,j} = net.LW{i,j} + dw;
            end
          end

          % Update Bias Values
          if net.biasConnect(i)
            fcn = fcns.biases(i).learn;
            if fcn.exist
             [db,BLS{i}] = fcn.apply(net.b{i}, ...
                BP,divData.Zb{i},divData.N{i},divData.Ac{i,1+net.numLayerDelays},...
                [divData.T{ii,1}],[divData.E{ii,1}],gB{i,1},...
                gA{i,1},net.layers{i}.distances,fcn.param,BLS{i});
              net.b{i} = net.b{i} + db;
            end
          end
        end
      end

    [perf,vperf,tperf] = nn7.trainValTestPerfs(net,data,fcns);
  end
end
 
% TODO - Add Validation
% TODO - Add silent/fast mode
