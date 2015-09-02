function [out1,out2] = trainlm(varargin)
%TRAINLM Levenberg-Marquardt backpropagation.
%
%  <a href="matlab:doc trainlm">trainlm</a> is a network training function that updates weight and
%  bias states according to Levenberg-Marquardt optimization.
%
%  <a href="matlab:doc trainlm">trainlm</a> is often the fastest backpropagation algorithm in the toolbox,
%  and is highly recommended as a first choice supervised algorithm,
%  although it does require more memory than other algorithms.
%
%  [NET,TR] = <a href="matlab:doc trainlm">trainlm</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%  
%  [NET,TR] = <a href="matlab:doc trainlm">trainlm</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  Training occurs according to training parameters, with default values.
%  Any or all of these can be overridden with parameter name/value argument
%  pairs appended to the input argument list, or by appending a structure
%  argument with fields having one or more of these names.
%    show        25  Epochs between displays
%    showCommandLine 0 generate command line output
%    showWindow   1 show training GUI
%    epochs     100  Maximum number of epochs to train
%    goal         0  Performance goal
%    max_fail     5  Maximum validation failures
%    min_grad 1e-10  Minimum performance gradient
%    mu       0.001  Initial Mu
%    mu_dec     0.1  Mu decrease factor
%    mu_inc      10  Mu increase factor
%    mu_max    1e10  Maximum Mu
%    time       inf  Maximum time to train in seconds
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = '<a href="matlab:doc trainlm">trainlm</a>';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also trainscg, feedforwardnet, narxnet.

% Mark Beale, 11-31-97, ODJ 11/20/98
% Updated by Orlando De Jesús, Martin Hagan, Dynamic Training 7-20-05
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.17 $ $Date: 2012/04/20 19:14:16 $

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

function info = get_info()
  isSupervised = true;
  usesGradient = false;
  usesJacobian = true;
  usesValidation = true;
  supportsCalcModes = true;
  info = nnfcnTraining(mfilename,'Levenberg-Marquardt',8.0,...
    isSupervised,usesGradient,usesJacobian,usesValidation,supportsCalcModes,...
    [ ...
    nnetParamInfo('showWindow','Show Training Window Feedback','nntype.bool_scalar',true,...
    'Display training window during training.'), ...
    nnetParamInfo('showCommandLine','Show Command Line Feedback','nntype.bool_scalar',false,...
    'Generate command line output during training.'), ...
    nnetParamInfo('show','Command Line Frequency','nntype.strict_pos_int_inf_scalar',25,...
    'Frequency to update command line.'), ...
    ...
    nnetParamInfo('epochs','Maximum Epochs','nntype.pos_int_scalar',1000,...
    'Maximum number of training iterations before training is stopped.'), ...
    nnetParamInfo('time','Maximum Training Time','nntype.pos_inf_scalar',inf,...
    'Maximum time in seconds before training is stopped.'), ...
    ...
    nnetParamInfo('goal','Performance Goal','nntype.pos_scalar',0,...
    'Performance goal.'), ...
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-7,...
    'Minimum performance gradient before training is stopped.'), ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.strict_pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.'), ...
    ...
    nnetParamInfo('mu','Mu','nntype.pos_scalar',0.001,...
    'Mu.'), ...
    nnetParamInfo('mu_dec','Mu Decrease Ratio','nntype.real_0_to_1',0.1,...
    'Ratio to decrease mu.'), ...
    nnetParamInfo('mu_inc','Mu Increase Ratio','nntype.over1',10,...
    'Ratio to increase mu.'), ...
    nnetParamInfo('mu_max','Maximum mu','nntype.strict_pos_scalar',1e10,...
    'Maximum mu before training is stopped.'), ...
    ], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('mu','Mu','continuous','log') ...
    nntraining.state_info('val_fail','Validation Checks','discrete','linear') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = formatNet(net)
  if isempty(net.performFcn)
    warning('nnet:trainlm:Performance',nnwarning.empty_performfcn_corrected);
    net.performFcn = 'mse';
    net.performParam = mse('defaultParam');
  end
  if isempty(nnstring.first_match(net.performFcn,{'sse','mse'}))
    warning('nnet:trainlm:Performance',nnwarning.nonjacobian_performfcn_replaced);
    net.performFcn = 'mse';
    net.performParam = mse('defaultParam');
  end
end

function [calcNet,tr] = train_network(archNet,rawData,calcLib,calcNet,tr)
  
  % Parallel Workers
  isParallel = calcLib.isParallel;
  isMainWorker = calcLib.isMainWorker;
  mainWorkerInd = calcLib.mainWorkerInd;

  % Create broadcast variables
  stop = [];
  muBreak = [];
  perfBreak = [];
  WB2 = [];
  
  % Initialize
  param = archNet.trainParam;
  if isMainWorker
    startTime = clock;
    original_net = calcNet;
  end
  
  [perf,vperf,tperf,je,jj,gradient] = calcLib.perfsJEJJ(calcNet);
  
  if isMainWorker
    [best,val_fail] = nntraining.validation_start(calcNet,perf,vperf);
    WB = calcLib.getwb(calcNet);
    lengthWB = length(WB);
    ii = sparse(1:lengthWB,1:lengthWB,ones(1,lengthWB));
    mu = param.mu;

    % Training Record
    tr.best_epoch = 0;
    tr.goal = param.goal;
    tr.states = {'epoch','time','perf','vperf','tperf','mu','gradient','val_fail'};

    % Status
    status = ...
      [ ...
      nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
      nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
      nntraining.status('Performance','','log','continuous',perf,param.goal,perf) ...
      nntraining.status('Gradient','','log','continuous',gradient,param.min_grad,gradient) ...
      nntraining.status('Mu','','log','continuous',mu,param.mu_max,mu) ...
      nntraining.status('Validation Checks','','linear','discrete',0,param.max_fail,0) ...
      ];
    nn_train_feedback('start',archNet,status);
  end

  % Train
  for epoch = 0:param.epochs

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
      elseif (mu >= param.mu_max), tr.stop = 'Maximum MU reached.'; calcNet = best.net;
      elseif (val_fail >= param.max_fail), tr.stop = 'Validation stop.'; calcNet = best.net;
      end

      % Feedback
      tr = nntraining.tr_update(tr,[epoch current_time perf vperf tperf mu gradient val_fail]);
      statusValues = [epoch,current_time,best.perf,gradient,mu,val_fail];
      nn_train_feedback('update',archNet,rawData,calcLib,calcNet,tr,status,statusValues);
      stop = ~isempty(tr.stop);
    end

    % Stop
    if isParallel, stop = labBroadcast(mainWorkerInd,stop); end
    if stop, break, end

    % Levenberg Marquardt
    while true
      if isMainWorker, muBreak = (mu > param.mu_max); end
      if isParallel, muBreak = labBroadcast(mainWorkerInd,muBreak); end
      if muBreak, break; end
    
      if isMainWorker
        % Check for Singular Matrix
        [msgstr,msgid] = lastwarn;
        lastwarn('MATLAB:nothing','MATLAB:nothing')
        warnstate = warning('off','all');
        dWB = -(jj+ii*mu) \ je;
        [~,msgid1] = lastwarn;
        flag_inv = isequal(msgid1,'MATLAB:nothing');
        if flag_inv, lastwarn(msgstr,msgid); end;
        warning(warnstate)
        WB2 = WB + dWB;
      end
      
      calcNet2 = calcLib.setwb(calcNet,WB2);
      perf2 = calcLib.trainPerf(calcNet2);

      if isMainWorker, perfBreak = (perf2 < perf) && flag_inv; end
      if isParallel, perfBreak = labBroadcast(mainWorkerInd,perfBreak); end
      if perfBreak
        WB = WB2;
        calcNet = calcNet2;
        if isMainWorker
          mu = max(mu*param.mu_dec,1e-20);
        end
        break
      end
      
      if isMainWorker
        mu = mu * param.mu_inc;
      end
    end
    
    % Validation
    [perf,vperf,tperf,je,jj,gradient] = calcLib.perfsJEJJ(calcNet);
    if isMainWorker
      [best,tr,val_fail] = nntraining.validation(best,tr,val_fail,calcNet,perf,vperf,epoch);
    end
  end
end

