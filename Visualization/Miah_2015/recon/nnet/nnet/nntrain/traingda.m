function [out1,out2] = traingda(varargin)
%TRAINGDA Gradient descent with adaptive lr backpropagation.
%
%  <a href="matlab:doc traingda">traingda</a> is a network training function that updates weight and
%  bias values according to gradient descent with adaptive
%  learning rate.
%
%  [NET,TR] = <a href="matlab:doc traingda">traingda</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%  
%  [NET,TR] = <a href="matlab:doc traingda">traingda</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  Training occurs according to training parameters, with default values.
%  Any or all of these can be overridden with parameter name/value argument
%  pairs appended to the input argument list, or by appending a structure
%  argument with fields having one or more of these names.
%    show           25  Epochs between displays
%    showCommandLine 0 generate command line output
%    showWindow      1 show training GUI
%    epochs         10  Maximum number of epochs to train
%    goal            0  Performance goal
%    lr           0.01  Learning rate
%    lr_inc       1.05  Ratio to increase learning rate
%    lr_dec        0.7  Ratio to decrease learning rate
%    max_fail        5  Maximum validation failures
%    max_perf_inc 1.04  Maximum performance increase
%    min_grad    1e-10  Minimum performance gradient
%    time          inf  Maximum time to train in seconds
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'traingda';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also NEWFF, NEWCF, TRAINGD, TRAINGDM, TRAINGDX, TRAINLM.

% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% Mark Beale, 11-31-97
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.16 $ $Date: 2012/04/20 19:14:13 $

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
  usesValidation = true;
  supportsCalcModes = true;
  info = nnfcnTraining(mfilename,'Gradient Descent with Adaptive Learning Rate',8.0,...
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
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-5,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.strict_pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('lr','Learning Rate','nntype.pos_scalar',0.01,...
    'Learning rate.') ...
    nnetParamInfo('lr_inc','Learning Rate Increase','nntype.over1',1.05,...
    'Learning rate increase mulitiplier.') ...
    nnetParamInfo('lr_dec','Learning Rate','nntype.real_0_to_1',0.7,...
    'Learning rate decrease mulitiplier.') ...
    nnetParamInfo('max_perf_inc','Maximum Performance Increase','nntype.strict_pos_scalar',1.04,...
    'Maximum acceptable increase in performance.') ...
    ], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('val_fail','Validation Checks','discrete','linear') ...
    nntraining.state_info('lr','Learning Rate','continuous','linear') ...
    ]);
  
  % TODO - LR to initLR
end

function err = check_param(param)
  err = '';
end

function net = formatNet(net)
  if isempty(net.performFcn)
    warning('nnet:traingda:Performance',nnwarn_empty_performfcn_corrected);
    net.performFcn = 'mse';
  end
end

function [calcNet,tr] = train_network(archNet,rawData,calcLib,calcNet,tr)
  
  % Parallel Workers
  isParallel = calcLib.isParallel;
  isMainWorker = calcLib.isMainWorker;
  mainWorkerInd = calcLib.mainWorkerInd;

  % Create broadcast variables
  stop = []; 
  WB2 = [];

  % Initialize
  param = archNet.trainParam;
  if isMainWorker
      startTime = clock;
      original_net = calcNet;
  end
  
  [perf,vperf,tperf,gWB,gradient] = calcLib.perfsGrad(calcNet);
  
  if isMainWorker
      [best,val_fail] = nntraining.validation_start(calcNet,perf,vperf);
      WB = calcLib.getwb(calcNet);
      lr = param.lr;

      % Training Record
      tr.best_epoch = 0;
      tr.goal = param.goal;
      tr.states = {'epoch','time','perf','vperf','tperf','gradient','val_fail','lr'};

      % Status
      status = ...
        [ ...
        nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
        nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
        nntraining.status('Performance','','log','continuous',perf,param.goal,perf) ...
        nntraining.status('Gradient','','log','continuous',gradient,param.min_grad,gradient) ...
        nntraining.status('Validation Checks','','linear','discrete',0,param.max_fail,0) ...
        ];
      nn_train_feedback('start',archNet,status);
  end

  %% Train
  for epoch=0:param.epochs

    % Stopping Criteria
    if isMainWorker
        current_time = etime(clock,startTime);
        [userStop,userCancel] = nntraintool('check');
        if userStop, tr.stop = 'User stop.'; calcNet = best.net;
        elseif userCancel, tr.stop = 'User cancel.'; calcNet = original_net;
        elseif (perf <= param.goal), tr.stop = 'Performance goal met.'; calcNet = best.net;
        elseif (epoch == param.epochs), tr.stop = 'Maximum epoch reached.'; calcNet = best.net;
        elseif (current_time >= param.time), tr.stop = 'Maximum time elapsed.'; calcNet = best.net;
        elseif (gradient <= param.min_grad), tr.stop = 'Minimum gradient reached.'; calcNet = best.net;
        elseif (val_fail >= param.max_fail), tr.stop = 'Validation stop.'; calcNet = best.net;
        end

        % Training record & feedback
        tr = nntraining.tr_update(tr,[epoch current_time perf vperf tperf gradient val_fail lr]);
        statusValues = [epoch,current_time,best.perf,gradient,val_fail];
        nn_train_feedback('update',archNet,rawData,calcLib,calcNet,tr,status,statusValues);
        stop = ~isempty(tr.stop);
    end
    
    % Stop
    if isParallel, stop = labBroadcast(mainWorkerInd,stop); end
    if stop, return, end

    % Gradient Descent with Adaptive Learning Rate
    if isMainWorker
        dWB = lr*gWB;
        WB2 = WB + dWB;
    end
    
    calcNet2 = calcLib.setwb(calcNet,WB2);
    [perf2,vperf2,tperf2,gWB2,gradient2] = calcLib.perfsGrad(calcNet2);
    
    if isMainWorker
        if (perf2/perf) > param.max_perf_inc
          lr = lr * param.lr_dec;
        else
          if (perf2 < perf), lr = lr * param.lr_inc; end
          [calcNet,WB,perf,vperf,tperf,gWB,gradient] = deal(calcNet2,WB2,perf2,vperf2,tperf2,gWB2,gradient2);
        end

        % Validation
        if isMainWorker
            [best,tr,val_fail] = nntraining.validation(best,tr,val_fail,calcNet,perf,vperf,epoch);
        end
    end
  end
end

