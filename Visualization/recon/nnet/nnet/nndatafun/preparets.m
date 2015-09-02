function [x,xi,ai,t,ew,shift] = preparets(net,inputs,targets,feedback,ew)
%PREPARETS Prepare time series data for network simulation or training.
%
% <a href="matlab:doc preparets">preparets</a> takes timeseries data and prepares it for training or
% simuliation with a particular dynamic neural network.  It does this by
% shifting data as many timesteps as needed to define initial input and
% layer delays.
%
% [Xs,Xi,Ai,Ts,EWs,SHIFT] = <a href="matlab:doc preparets">preparets</a>(net,X,T,{},EW) takes inputs X,
% targets T, and error weights EW and returns shifted inputs Xs, initial
% input states Xi, initial layer states Ai, shifted targets Ts, and shifted
% error weights EWs.
%
% The value SHIFT represents how many initial timesteps of each series
% X and T were used to fill input delay states. For instance, if the
% network's maximum input delay was 5, then SHIFT will be 5, and the first
% 5 timesteps of X, T and EW will used to fill delay states. Xs, Ts and EWs
% will be 5 timesteps shorter than X, T and EW, so that Xs{:,1} will be
% equal to X{:,6}, Ts{:,1} will equal to T{:,6} and EWs{:,1} will be equal
% to EWs{:,6) if EW has more than one column (otherwise it will be
% unchanged.)
%
% Here a time-delay network with 20 hidden neurons is created, trained
% and simulated.
%
%   net = <a href="matlab:doc timedelaynet">timedelaynet</a>(10);
%   [X,T] = <a href="matlab:doc simpleseries_dataset">simpleseries_dataset</a>;
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts);
%   Y = net(Xs,Xi,Ai)
%
% For networks with explicit feedback outputs (that is a network with one
% or more layers where NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackMode">feedbackMode</a> is equal to 'open' or
% 'closed') then PREPARETS uses data associated with the feedback data
% to define the feedback output's targets, layer delay states, and
% input data for inputs associated with open feedback outputs.
%
% [Xs,Xi,Ai,Ts,EWs,SHIFT] = <a href="matlab:doc preparets">preparets</a>(net,Xnf,Tnf,Tfb,EW), where Xnf
% is the non-feedback input data (inputs not associated with an open loop
% feedback output), Tnf is the target data for non-feedback outputs. Tfb
% is the target data for outputs with feedback.
%
% In this case, SHIFT will be equal to the maximum input delay or closed
% loop layer delay.  Xs and Ts will be SHIFT columns shorter than Xnf, Tnf
% Tfb and EW.
%
% The arguments Tnf, Tfb and EW are optional. They can be left out of
% the argument list or set to the empty cell {}.
%
% Here a NARX network is designed. The NARX network has a standard input
% and an open loop feedback output to an associated feedback input.
%
%   [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%   net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%   <a href="matlab:doc view">view</a>(net)
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%   y = net(Xs,Xi,Ai);
%
% Now the network is converted to closed loop, and the data is reformatted
% to simulate the network's closed loop response.
%
%   net = <a href="matlab:doc closeloop">closeloop</a>(net);
%   <a href="matlab:doc view">view</a>(net)
%   [Xs,Xi,Ai] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   y = net(Xs,Xi,Ai);
%
%  See also TIMEDELAYNET, NARNET, NARXNET, NTSTOOL, OPENLOOP, CLOSELOOP

% Copyright 2010-2012 The MathWorks, Inc.

% Argument checks
if nargin < 2, error(message('nnet:Args:NotEnough')); end
if nargin < 3, targets = {}; end
if nargin < 4, feedback = {}; end
if nargin < 5, ew = {1}; end
nntype.network('assert',net,'''NET''');
inputs = nntype.data('format',inputs,'Inputs');
feedback = nntype.data('format',feedback,'Feedback');
targets = nntype.data('format',targets,'Targets');
ew = nntype.data('format',ew,'Error weights');

% Q and TS
if size(inputs,2) ~= 0
  Q = nnfast.numsamples(inputs);
  TS = nnfast.numtimesteps(inputs);
elseif size(feedback,2) ~= 0
  Q = nnfast.numsamples(feedback);
  TS = nnfast.numtimesteps(feedback);
elseif size(targets,2) ~= 0
  Q = nnfast.numsamples(targets);
  TS = nnfast.numtimesteps(targets);
else
  Q = 0;
  TS = 0;
end

% Fill in empty data
if isempty(inputs)
  inputs = nndata(non_feedback_input_sizes(net),Q,TS,NaN);
end
if isempty(feedback)
  feedback = nndata(feedback_output_sizes(net),Q,TS,NaN);
elseif size(feedback,2) < TS
  error(message('nnet:NNData:FBXTimestepMismatch'))
end
if isempty(targets)
  targets = nndata(non_feedback_output_sizes(net),Q,TS,NaN);
elseif size(targets,2) ~= TS
  error(message('nnet:NNData:TXTimestepMismatch'))
end
if isempty(ew)
  ew = {1};
elseif size(ew,2)>1
  ew = extendts(ew,TS,1);
end

% Error Weight Flag
if size(ew,2) == 1
  ewShift = false;
elseif size(ew,2) == TS
  ewShift = true;
else
  nnerr.throw(['Error weights does not have 1 or ' num2str(TS) ' timesteps.']); 
end

% Dimensions
inputSizes = nnfast.numelements(inputs);
targetSizes = nnfast.numelements(targets);
layerSizes  = nn.layer_sizes(net);

% Count open/closed/non-feedback inputs and outputs
numInputOnly = 0;
numInputFeedback = 0;
numOutputOnly = 0;
numOutputFeedback = 0;
numOutputOpenFeedback = 0;
numOutputClosedFeedback = 0;
for i=1:net.numInputs
  if isempty(net.inputs{i}.feedbackOutput)
    numInputOnly = numInputOnly + 1;
  else
    numInputFeedback = numInputFeedback + 1;
  end
end
for i=find(net.outputConnect)
  if strcmp(net.outputs{i}.feedbackMode,'none')
    numOutputOnly = numOutputOnly + 1;
  else
    numOutputFeedback = numOutputFeedback + 1;
    if isempty(net.outputs{i}.feedbackInput)
      numOutputClosedFeedback = numOutputClosedFeedback + 1;
    else
      numOutputOpenFeedback = numOutputOpenFeedback + 1;
    end
  end
end

% Determine whether closedFeedback and targets are available
if numsignals(inputs) ~= numInputOnly
  error(message('nnet:NNet:XnFBXMismatch'));
end
if numsignals(feedback) == numOutputFeedback
  closedFeedbackAvail = true;
elseif numsignals(feedback) == numInputFeedback
  closedFeedbackAvail = false;
elseif numsignals(feedback) == 0
  closedFeedbackAvail = false;
else
  nnerr.throw('Args',sprintf(...
    ['Number of feedback signals not equal to all feedback (%g)' ...
    ' or open feedback (%g) outputs.'],numOutputFeedback,numInputFeedback));
end
if numsignals(targets) ~= numOutputOnly
  error(message('nnet:NNet:YnFBYMismatch'));
end

% Index argument data signals by category
inputOnlyInd = [];
inputFeedbackInd = [];
outputOnlyInd = [];
outputOnlyDelays = [];
outputOpenFeedbackInd = [];
outputClosedFeedbackInd = [];
closedFeedback = {};
openFeedback = {};
openFeedbackDelays = [];
closedFeedbackDelays = [];
output2layer = find(net.outputConnect);
for i=1:net.numInputs
  if isempty(net.inputs{i}.feedbackOutput)
    inputOnlyInd = [inputOnlyInd i];
  end
end
fbpos = 0;
for i=1:net.numOutputs
  ii = output2layer(i);
  if strcmp(net.outputs{ii}.feedbackMode,'none')
    outputOnlyInd = [outputOnlyInd i];
    outputOnlyDelays = [outputOnlyDelays net.outputs{ii}.feedbackDelay];
  else
    fbpos = fbpos + 1;
    fbi = net.outputs{ii}.feedbackInput;
    if isempty(fbi)
      outputClosedFeedbackInd = [outputClosedFeedbackInd i];
      closedFeedback = [closedFeedback; feedback(fbpos,:)];
      closedFeedbackDelays = [closedFeedbackDelays net.outputs{ii}.feedbackDelay];
    else
      inputFeedbackInd = [inputFeedbackInd fbi];
      outputOpenFeedbackInd = [outputOpenFeedbackInd i];
      openFeedback = [openFeedback; feedback(fbpos,:)];
      openFeedbackDelays = [openFeedbackDelays net.outputs{ii}.feedbackDelay];
    end
  end
end

% Dimensions
xSizes = zeros(1,net.numInputs);
xSizes(inputOnlyInd) = inputSizes;
xSizes(inputFeedbackInd) = nnfast.numelements(openFeedback);
tSizes = zeros(1,net.numOutputs);
tSizes(outputOnlyInd) = targetSizes;
tSizes(outputClosedFeedbackInd) = nnfast.numelements(closedFeedback);
tSizes(outputOpenFeedbackInd) = nnfast.numelements(openFeedback);

% Merge feedback with non-feedback inputs and targets
FBDelay = max([0 max(outputOnlyDelays) max(openFeedbackDelays) max(closedFeedbackDelays)]);
TSind = FBDelay+(1:TS);
xx = nndata(xSizes,Q,FBDelay+TS,0);
tt = nndata(tSizes,Q,FBDelay+TS,NaN);
inputShift = net.numInputDelays;
layerShift = net.numLayerDelays;

% Pure inputs
if ~isempty(inputOnlyInd)
  xx(inputOnlyInd,TSind) = inputs;
end

% Open loop feedback as inputs (unshifted)
if ~isempty(inputFeedbackInd)
  xx(inputFeedbackInd,TSind) = openFeedback;
end

% Pure targets (shifted)
if ~isempty(outputOnlyInd)
  for i = 1:numOutputOnly
    ii = outputOnlyInd(i);
    d = outputOnlyDelays(i);
    tt(ii,TSind-d) = targets(i,:);
  end
end

% Open loop feedback as targets (shifted)
if ~isempty(outputOpenFeedbackInd)
  for i=1:length(outputOpenFeedbackInd)
    d = openFeedbackDelays(i);
    tt(outputOpenFeedbackInd(i),TSind-d) = openFeedback(i,:);
  end
end

% Closed loop feedback as targets (shifted)
if closedFeedbackAvail && ~isempty(outputClosedFeedbackInd)
  for i=1:length(outputClosedFeedbackInd)
    d = closedFeedbackDelays(i);
    ii = outputClosedFeedbackInd(i);
    tt(ii,TSind-d) = closedFeedback(i,:);
    layerInd = output2layer(ii);
    for layerToInd = find(net.layerConnect(:,layerInd)')
      layerShift1 = max(net.layerWeights{layerToInd,layerInd}.delays)-d;
      layerShift = max([layerShift layerShift1]);
    end
  end
end

% Configure network
for i=1:net.numInputs
  if (net.inputs{i}.size ~= xSizes(i)) && (net.inputs{i}.size == 0)
    net = configure(net,'input',xx(i,:),i);
  end
end
netOutputSizes = nn.output_sizes(net);
for i=1:net.numOutputs
  if (netOutputSizes(i) ~= tSizes(i)) && (netOutputSizes(i) == 0)
    net = configure(net,'output',tt(i,:),i);
  end
end

% Calculate time shift
shift = max(inputShift,layerShift);

% Divide up inputs, input states, layer states, targets
FBS = FBDelay + shift;
xi = xx(:,FBS+((1-net.numInputDelays):0));
x = xx(:,(FBS+1):end);
ai = nndata(layerSizes,Q,net.numLayerDelays,0);
if closedFeedbackAvail
  ti = tt(:,FBS+((1-net.numLayerDelays):0));
  ai(net.outputConnect,:) = pre_process_targets(net,ti);
end
t = tt(:,(FBS+1):end);

% Error Weights
if ewShift
  ew = ew(:,(FBS+1):end);
end

function n = non_feedback_input_sizes(net)
n = [];
for i=1:net.numInputs
  if isempty(net.inputs{i}.feedbackOutput)
    n = [n net.inputs{i}.size];
  end
end

function n = feedback_output_sizes(net)
n = zeros(1,net.numLayers);
for i=net.numLayers:-1:1
  if ~net.outputConnect(i) || strcmp(net.outputs{i}.feedbackMode,'none')
    n(i) = [];
  else
    n(i) = net.outputs{i}.size;
  end
end

function n = non_feedback_output_sizes(net)
n = zeros(1,net.numLayers);
for i=net.numLayers:-1:1
  if ~net.outputConnect(i) || ~strcmp(net.outputs{i}.feedbackMode,'none')
    n(i) = [];
  else
    n(i) = net.outputs{i}.size;
  end
end

function t=pre_process_targets(net,t)
output2layer = find(net.outputConnect); 
for i=1:net.numOutputs
  ii = output2layer(i);
  t(i,:) = process_forward(net.outputs{ii}.processFcns,net.outputs{ii}.processSettings,t(i,:));
end

function x = process_forward(pfcns,psettings,x)
for ts = 1:size(x,2)
  xts = x{1,ts};
  for k = 1:numel(pfcns);
    info = feval(pfcns{k},'info');
    xts = info.apply(xts,psettings{k});
  end
  x{1,ts} = xts;
end

