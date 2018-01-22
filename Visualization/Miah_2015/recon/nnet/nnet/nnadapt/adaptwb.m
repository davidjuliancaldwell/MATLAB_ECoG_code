function [out1,out2,out3] = adaptwb(in1,in2,in3,in4,in5,in6)
%ADAPTWB Sequential order incremental adaption w/learning functions.
%
%  [NET,AR,AC] = <a href="matlab:doc adaptwb">adaptwb</a>(NET,PD,T,AI) takes a network, delayed inputs,
%  targets, and initial layer states, and returns the updated network,
%  adaption record, and layer outputs after applying the network's
%  weight and bias learning rules for each timestep in T.
%
%  <a href="matlab:doc adaptwb">adaptwb</a> is not commonly called directly, it is called by ADAPT when
%  the network's adaption function net.<a href="matlab:doc nnproperty.net_adaptFcn">adaptFcn</a> is set to <a href="matlab:doc adaptwb">adaptwb</a>.

% Mark Beale, 11-31-97
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.10.7 $  $Date: 2012/03/27 18:08:27 $

% TODO - Replace PD with Xc, TAPDELAY, return Yc?

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Adapt Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  if ischar(in1)
    switch (in1)
      case 'info'
        out1 = INFO;
      case 'check_param'
        out1 = check_param(in2);
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    [out1,out2,out3] = adapt_network(in1,in2,in3,in4);
  end
end

%  BOILERPLATE_END
%% =======================================================

function [net,Ac,tr] = adapt_network(net,PD,T,Ai)

  Q = numsamples(T);
  TS = numtimesteps(T);
  hints = nn7.netHints(net);
  hints = nn.connections(net,hints);
  hints.simLayerOrder = nn.layer_order(net);
  hints.outputInd = find(net.outputConnect);
  
  % Constants
  numLayers = net.numLayers;
  numInputs = net.numInputs;
  performFcn = net.performFcn;
  performParam = net.performParam;
  needGradient = nn.needsGradient(net);
  numLayerDelays = net.numLayerDelays;

  %Signals
  BP = ones(1,Q);
  IWLS = cell(net.numLayers,net.numInputs);
  LWLS = cell(net.numLayers,net.numLayers);
  BLS = cell(net.numLayers,1);
  Ac = [Ai cell(net.numLayers,TS)];
  gIW = cell(numLayers,numInputs);
  gLW = cell(numLayers,numLayers);
  gB = cell(net.numLayers,1);
  gA = cell(net.numLayers,1);
  AiInd = 0:(numLayerDelays-1);
  AcInd = 0:numLayerDelays;
  Al = cell(numLayers,TS);
  Y = cell(net.numOutputs,TS);
  E = cell(net.numOutputs,TS);
  gE = cell(net.numLayers,1);
    
  % Initialize
  tr.timesteps = 1:TS;
  tr.perf = zeros(1,TS);
  
  % Adapt
  for ts=1:TS

    % Simulate
    [Ac(:,ts+numLayerDelays),N,LWZ,IWZ,BZ] = nnMATLAB.a1(net,PD(:,:,ts),Ac(:,ts+AiInd),Q,hints);
    Al(:,ts) = Ac(:,numLayerDelays+ts);
    Y(:,ts) = nnMATLAB.post_outputs(hints,Al(hints.outputInd,ts));
    E(:,ts) = gsubtract(T(:,ts),Y(:,ts));
    if isempty(performFcn)
      tr.perf(ts) = 0;
    else
      tr.perf(ts) = nncalc.perform(net,T(:,ts),Y(:,ts),{1},performParam);
    end
    
    % Gradient
    if (needGradient)
      gE(net.outputConnect,:) = nncalc.dperform(net,T(:,ts), ...
        Y(:,ts),{1},net.performParam);
      [gB,gIW,gLW] = nn7.grad2(net,[],PD(:,:,ts),BZ,IWZ,LWZ,N,Ac(:,ts+AcInd),gE,Q,1,hints);
    end

    % Update
    for i=1:net.numLayers
      ii = hints.layer2output(i);
      if (ii==0), ii = []; end
      if isempty(ii), t = []; e = []; else t = T{ii,ts}; e = E{ii,ts}; end
          
      % Update Input Weight Values
      for j=find(net.inputConnect(i,:))
        learnFcn = net.inputWeights{i,j}.learnFcn;
        if ~isempty(learnFcn)
          [dw,IWLS{i,j}] = feval(learnFcn,net.IW{i,j}, ...
            PD{i,j,ts},IWZ{i,j},N{i},Ac{i,ts+numLayerDelays},t,e,gIW{i,j},...
            gA{i},net.layers{i}.distances,net.inputWeights{i,j}.learnParam,IWLS{i,j});
          net.IW{i,j} = net.IW{i,j} + dw;
        end
      end

      % Update Layer Weight Values
      for j=find(net.layerConnect(i,:))
          learnFcn = net.layerWeights{i,j}.learnFcn;
        if ~isempty(learnFcn)
            Ad = cell2mat(Ac(j,ts+numLayerDelays-net.layerWeights{i,j}.delays)');
            [dw,LWLS{i,j}] = feval(learnFcn,net.LW{i,j}, ...
            Ad,LWZ{i,j},N{i},Ac{i,ts+numLayerDelays},t,e,gLW{i,j},...
            gA{i},net.layers{i}.distances,net.layerWeights{i,j}.learnParam,LWLS{i,j});
            net.LW{i,j} = net.LW{i,j} + dw;
        end
      end

      % Update Bias Values
      if net.biasConnect(i)
        learnFcn = net.biases{i}.learnFcn;
        if ~isempty(learnFcn)
          [db,BLS{i}] = feval(learnFcn,net.b{i}, ...
          BP,BZ{i},N{i},Ac{i,ts+numLayerDelays},t,e,gB{i},...
          gA{i},net.layers{i}.distances,net.biases{i}.learnParam,BLS{i});
          net.b{i} = net.b{i} + db;
        end
      end
    end
  end
end

function v = fcnversion
  v = 7;
end

%===============================================================

function info = get_info
  info = nnfcnAdaptive(mfilename,'Weight/Bias Rule Adaption',fcnversion,...
    true,true,[]);
end

function err = check_param(param)
  err = '';
end
