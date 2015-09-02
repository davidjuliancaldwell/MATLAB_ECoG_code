function [out1,out2] = trainscg(varargin)
%TRAINSCG Scaled conjugate gradient backpropagation.
%
%  <a href="matlab:doc trainscg">trainscg</a> is a network training function that updates weight and
%  bias values according to the scaled conjugate gradient method.
%
%  [NET,TR] = <a href="matlab:doc trainscg">trainscg</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%  
%  [NET,TR] = <a href="matlab:doc trainscg">trainscg</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  Training occurs according to training parameters, with default values.
%  Any or all of these can be overridden with parameter name/value argument
%  pairs appended to the input argument list, or by appending a structure
%  argument with fields having one or more of these names.
%    show             25  Epochs between displays
%    showCommandLine   0 generate command line output
%    showWindow        1 show training GUI
%    epochs          100  Maximum number of epochs to train
%    goal              0  Performance goal
%    time            inf  Maximum time to train in seconds
%    min_grad       1e-6  Minimum performance gradient
%    max_fail          5  Maximum validation failures
%    sigma        5.0e-5  Determines change in weight for second derivative approximation.
%    lambda       5.0e-7  Parameter for regulating the indefiniteness of the Hessian.
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'trainscg';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also NEWFF, NEWCF, TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM,
%           TRAINRP, TRAINCGF, TRAINCGB, TRAINBFG, TRAINCGP,
%           TRAINOSS.

% Updated by Orlando De Jesús, Martin Hagan, Dynamic Training 7-20-05
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.17 $ $Date: 2012/04/20 19:14:22 $

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
  usesGradient = true;
  usesJacobian = false;
  usesValidation = true;
  supportsCalcModes = true;
  info = nnfcnTraining(mfilename,'Scaled Conjugate Gradient',8.0,...
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
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-6,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.strict_pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('sigma','Sigma','nntype.pos_scalar',5.0e-5,...
    'Determines change in weight for second derivative approximation.') ...
    nnetParamInfo('lambda','Lambda','nntype.pos_scalar',5.0e-7,...
    'Parameter for regulating the indefiniteness of the Hessian.') ...
    ], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('val_fail','Validation Checks','discrete','linear') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = formatNet(net)
  if isempty(net.performFcn)
    warning('nnet:trainsgc:Performance',nnwarn_empty_performfcn_corrected);
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
  success = [];
  WB_temp = [];

  % Initialize
  param = archNet.trainParam;
  if isMainWorker
    startTime = clock;
    originalNet = calcNet;
  end

  [perf,vperf,tperf,gWB,gradient] = calcLib.perfsGrad(calcNet);

  if isMainWorker
    [best,val_fail] = nntraining.validation_start(calcNet,perf,vperf);
    WB = calcLib.getwb(calcNet);
    lengthWB = length(WB);
    success = 1;
    lambdab = 0;
    lambdak = param.lambda;

    % Initial search direction and norm
    dWB = gWB;
    nrmsqr_dWB = dWB'*dWB;
    norm_dWB = sqrt(nrmsqr_dWB);

   % Training Record
    tr.best_epoch = 0;
    tr.goal = param.goal;
    tr.states = {'epoch','time','perf','vperf','tperf','gradient','val_fail'};

    %% Status
    status = ...
      [ ...
      nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
      nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
      nntraining.status('Performance','','log','continuous',best.perf,param.goal,best.perf) ...
      nntraining.status('Gradient','','log','continuous',gradient,param.min_grad,gradient) ...
      nntraining.status('Validation Checks','','linear','discrete',0,param.max_fail,0) ...
      ];
    nn_train_feedback('start',archNet,status);
  end

  % Train
  for epoch=0:param.epochs

    % Stopping Criteria
    if isMainWorker
      current_time = etime(clock,startTime);
      [userStop,userCancel] =  nntraintool('check');
      if userStop, tr.stop = 'User stop.'; calcNet = best.net;
      elseif userCancel, tr.stop = 'User cancel.'; calcNet = originalNet;
      elseif (perf <= param.goal), tr.stop = 'Performance goal met.'; calcNet = best.net;
      elseif (epoch == param.epochs), tr.stop = 'Maximum epoch reached.'; calcNet = best.net;
      elseif (current_time >= param.time), tr.stop = 'Maximum time elapsed.'; calcNet = best.net;
      elseif (gradient <= param.min_grad), tr.stop = 'Minimum gradient reached.'; calcNet = best.net;
      elseif (val_fail >= param.max_fail), tr.stop = 'Validation stop.'; calcNet = best.net;
      end

      % Training record & feedback
      tr = nntraining.tr_update(tr,[epoch current_time perf vperf tperf gradient val_fail]);
      statusValues = [epoch,current_time,best.perf,gradient,val_fail];
      nn_train_feedback('update',archNet,rawData,calcLib,calcNet,tr,status,statusValues);
      stop = ~isempty(tr.stop);
    end

    % Stop
    if isParallel,  stop = labBroadcast(mainWorkerInd,stop); end
    if stop, break, end

    % If success is true, calculate second order information
    if isParallel, success = labBroadcast(mainWorkerInd,success); end
    if (success == 1)
      if isMainWorker
        sigmak = param.sigma/norm_dWB;
        WB_temp = WB + sigmak*dWB;
      end
      net_temp = calcLib.setwb(calcNet,WB_temp);
      gWB_temp = calcLib.grad(net_temp);
      if isMainWorker
        sk = (gWB - gWB_temp)/sigmak;
        deltak = dWB'*sk;
      end
    end

    if isMainWorker
      % Scale deltak
      deltak = deltak + (lambdak - lambdab)*nrmsqr_dWB;

      % IF deltak <= 0 then make the Hessian matrix positive definite
      if (deltak <= 0)
        lambdab = 2*(lambdak - deltak/nrmsqr_dWB);
        deltak = -deltak + lambdak*nrmsqr_dWB;
        lambdak = lambdab;
      end

      % Calculate step
      muk = dWB'*gWB;
      alphak = muk/deltak;

      % Calculate the comparison parameter
      WB_temp = WB + alphak*dWB;
    end

    net_temp = calcLib.setwb(calcNet,WB_temp);
    [perf_temp,vperf2,tperf2,gWB_temp] = calcLib.perfsGrad(net_temp);

    if isMainWorker
      difk = 2*deltak*(perf - perf_temp)/(muk^2);

      % If difk >= 0 then a successful reduction in error can be made
      if (difk >= 0)
        gX_old = gWB;
        [calcNet,WB,perf,vperf,tperf,gWB] = deal(net_temp,WB_temp,perf_temp,vperf2,tperf2,gWB_temp);
        gradient = sqrt(gWB'*gWB);
        lambdab = 0;
        success = 1;
        
        % Restart the algorithm every lengthWB iterations
        if rem(epoch,lengthWB)==0
          dWB = gWB;
        else
          betak = (gWB'*gWB - gWB'*gX_old)/muk;
          dWB = gWB + betak*dWB;
        end
        nrmsqr_dWB = dWB'*dWB;
        norm_dWB = sqrt(nrmsqr_dWB);
        % If difk >= 0.75, then reduce the scale parameter
        if (difk >= 0.75), lambdak = 0.25*lambdak; end
      else
        lambdab = lambdak;
        success = 0;
      end

      % If difk < 0.25, then increase the scale parameter
      if (difk < 0.25) && nrmsqr_dWB~=0, 
        lambdak = lambdak + deltak*(1 - difk)/nrmsqr_dWB;
      end

      % Validation
      [best,tr,val_fail] = nntraining.validation(best,tr,val_fail,calcNet,perf,vperf,epoch);
    end
  end
end




