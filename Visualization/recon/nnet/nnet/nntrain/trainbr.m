function [out1,out2] = trainbr(varargin)
%TRAINBR Bayesian Regularization backpropagation.
%
%  <a href="matlab:doc trainbr">trainbr</a> is a network training function that updates the weight and
%  bias values according to Levenberg-Marquardt optimization.  It
%  minimizes a combination of squared errors and weights
%  and, then determines the correct combination so as to produce a
%  network which generalizes well.  The process is called Bayesian
%  regularization.
%
%  <a href="matlab:doc trainbr">trainbr</a> trains a network with weight and bias learning rules
%  with batch updates. The weights and biases are updated at the end of
%  an entire pass through the input data.
%  
%  [NET,TR] = <a href="matlab:doc trainbr">trainbr</a>(NET,X,T,Xi,Ai,EW) takes additional optional
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
%    mu       0.005  Marquardt adjustment parameter
%    mu_dec     0.1  Decrease factor for mu
%    mu_inc      10  Increase factor for mu
%    mu_max    1e10  Maximum value for mu
%    max_fail     5  Maximum validation failures
%    min_grad 1e-10  Minimum performance gradient
%    time       inf  Maximum time to train in seconds
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'trainbr';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also NEWFF, NEWCF, TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM,
%           TRAINRP, TRAINCGF, TRAINCGB, TRAINSCG, TRAINCGP,
%           TRAINBFG.

% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.22 $ $Date: 2012/04/20 19:14:05 $

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
  usesValidation = false;
  supportsCalcModes = true;
  info = nnfcnTraining(mfilename,'Bayesian Regulation',8.0,...
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
    ...
    nnetParamInfo('goal','Performance Goal','nntype.pos_scalar',0,...
    'Performance goal.') ...
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-7,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.strict_pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('mu','Mu','nntype.strict_pos_scalar',0.005,...
    'Mu.'), ...
    nnetParamInfo('mu_dec','Mu Decrease Ratio','nntype.strict_pos_scalar',0.1,...
    'Ratio to decrease mu.'), ...
    nnetParamInfo('mu_inc','Mu Increase Ratio','nntype.strict_pos_scalar',10,...
    'Ratio to increase mu.'), ...
    nnetParamInfo('mu_max','Maximum mu','nntype.strict_pos_scalar',1e10,...
    'Maximum mu before training is stopped.'), ...
    ], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('mu','Mu','continuous','log') ...
    nntraining.state_info('gamk','Num Parameters','continuous','linear') ...
    nntraining.state_info('ssX','Sum Squared Param','continuous','log') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = formatNet(net)
  if isempty(net.performFcn)
    disp([nnlink.fcn2ulink('trainbr') ': ' nnwarning.empty_performfcn_corrected]);
    net.performFcn = 'mse';
    net.performParam = mse('defaultParam');
    tr.performFcn = net.performFcn;
    tr.performParam = net.performParam;
  end
  if ~strcmp(net.performFcn,'sse') && ~strcmp(net.performFcn,'mse')
    disp([nnlink.fcn2ulink('trainbr') ': ' nnwarning.trainbr_performfcn_sse]);
    net.performFcn = 'mse';
    net.performParam = sse('defaultParam');
    tr.performFcn = net.performFcn;
    tr.performParam = net.performParam;
  end
  if isfield(net.performParam,'regularization')
    if net.performParam.regularization ~= 0
      disp([nnlink.fcn2ulink('trainbr') ': ' nnwarning.adaptive_reg_override])
      net.performParam.regression = 0;
    end
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
  X2 = [];
  
  % Initialize
  param = archNet.trainParam;
  if isMainWorker
      [~,numErrors] = meansqr(gmultiply(rawData.T,rawData.train.mask));
      if strcmp(archNet.performFcn,'mse')
        perfFactor = numErrors;
      else
        perfFactor = 1;
      end
      startTime = clock;
      original_net = calcNet;
      perfFactor = 1;
  end
  [xsE,vperf,tperf,je,jj,xgradient] = calcLib.perfsJEJJ(calcNet);
  if isMainWorker
      ssE = xsE * perfFactor;
      best.net = calcNet;
      best.perf = xsE;
      X = calcLib.getwb(calcNet);
      mu = param.mu;
      numParameters = length(X);
      ii = sparse(1:numParameters,1:numParameters,ones(1,numParameters));

      % Initialize regularization parameters
      gamk = numParameters;
      if ssE == 0, beta = 1; else beta = (numErrors - gamk)/(2*ssE); end
      if beta <=0, beta = 1; end
      ssX = X'*X;
      alph = gamk/(2*ssX);
      perf = beta*ssE + alph*ssX;

      % Training Record
      tr.best_epoch = 0;
      tr.goal = param.goal;
      tr.states = {'epoch','time','perf','vperf','tperf','mu','gradient','gamk','ssX'};

      % Status
      status = ...
        [ ...
        nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
        nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
        nntraining.status('Performance','','log','continuous',xsE,param.goal,xsE) ...
        nntraining.status('Gradient','','log','continuous',xgradient,param.min_grad,xgradient) ...
        nntraining.status('Mu','','log','continuous',mu,param.mu_max,mu) ...
        nntraining.status('Effective # Param','','linear','continuous',gamk,0,gamk) ...
        nntraining.status('Sum Squared Param','','log','continuous',ssX,0,ssX) ...
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
        elseif (xsE <= param.goal), tr.stop = 'Performance goal met.'; calcNet = best.net;
        elseif (epoch == param.epochs), tr.stop = 'Maximum epoch reached.'; calcNet = best.net;
        elseif (current_time >= param.time), tr.stop = 'Maximum time elapsed.'; calcNet = best.net;
        elseif (xgradient <= param.min_grad), tr.stop = 'Minimum gradient reached.'; calcNet = best.net;
        elseif (mu >= param.mu_max), tr.stop = 'Maximum MU reached.'; calcNet = best.net;
        end

        % Feedback
        tr = nntraining.tr_update(tr,[epoch current_time xsE vperf tperf mu xgradient gamk ssX]);
        statusValues = [epoch,current_time,xsE,xgradient,mu,gamk,ssX];
        nn_train_feedback('update',archNet,rawData,calcLib,calcNet,tr,status,statusValues);
        stop = ~isempty(tr.stop);
    end

    % Stop
    if isParallel, stop = labBroadcast(mainWorkerInd,stop); end
    if stop, return, end

    % APPLY LEVENBERG MARQUARDT: INCREASE MU TILL ERRORS DECREASE
    while true
      if isMainWorker, muBreak = (mu > param.mu_max); end
      if isParallel, muBreak = labBroadcast(mainWorkerInd,muBreak); end
      if muBreak, break; end
      
      if isMainWorker
          % CHECK FOR SINGULAR MATRIX
          [msgstr,msgid] = lastwarn;
          lastwarn('MATLAB:nothing','MATLAB:nothing')
          warnstate = warning('off','all');
          dX = -(beta*jj + ii*(mu+alph)) \ (beta*je + alph*X);
          [~,msgid1] = lastwarn;
          flag_inv = isequal(msgid1,'MATLAB:nothing');
          if flag_inv, lastwarn(msgstr,msgid); end;
          warning(warnstate);
          X2 = X + dX;
          ssX2 = X2'*X2;
      end
      
      calcNet2 = calcLib.setwb(calcNet,X2);
      xsE2 = calcLib.trainPerf(calcNet2);
      
      if isMainWorker
          ssE2 = xsE2 * perfFactor;
          perf2 = beta*ssE2 + alph*ssX2;
      end

      if isMainWorker, perfBreak = ((perf2 < perf) && ( ( sum(isinf(dX)) + sum(isnan(dX)) ) == 0 ) && flag_inv); end
      if isParallel, perfBreak = labBroadcast(mainWorkerInd,perfBreak); end
      if perfBreak
        if isMainWorker
            X = X2; ssX = ssX2; perf = perf2;calcNet = calcNet2;
        end
        calcNet = calcLib.setwb(calcNet,X2);
        if isMainWorker
            mu = mu * param.mu_dec;
            if (mu < 1e-20), mu = 1e-20; end
        end
        break
      end
      if isMainWorker
          mu = mu * param.mu_inc;
      end
    end
    [xsE,vperf,tperf,je,jj,xgradient] = calcLib.perfsJEJJ(calcNet);
    if isMainWorker
        ssE = xsE * perfFactor;
    end
    
    if isMainWorker
        if (mu <= param.mu_max)
          % Update regularization parameters and performance function
          warnstate = warning('off','all');
          gamk = numParameters - alph*trace(inv(beta*jj+ii*alph));
          warning(warnstate);
          if ssX==0, alph = 1; else alph = gamk/(2*(ssX)); end
          if ssE==0, beta = 1; else beta = (numErrors - gamk)/(2*ssE); end
          perf = beta*ssE + alph*ssX;
        end

        best.net = calcNet;
        best.perf = xsE;
        tr.best_epoch = epoch+1;
    end
  end
end
