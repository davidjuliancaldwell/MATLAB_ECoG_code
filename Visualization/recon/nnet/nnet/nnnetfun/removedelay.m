function net = removedelay(net,n)
%REMOVEDELAY Remove a delay to a neural network's response.
%
% <a href="matlab:doc removedelay">removedelay</a>(NET) returns a network whose output responds one time
% step earlier then the original network.
%
% <a href="matlab:doc removedelay">removedelay</a>(NET,N) returns a network whose response is N time
% steps earler than the original network.
%
% In both cases, the reduced number of delays N are implemented by
% subtracting N from the delays of each input weight.
%  
% If a network has a feedback output, then N is subtracted from its
% feedback delay to indicate it generates outputs N steps later
% than it did before.
%
% For example, here a NARXNET is created and trained to predict the
% output of a system from past values of that feedback as input and
% another input.
%
% Here a NARX network is designed. The NARX network has a standard input
% and an open loop feedback output to an associated feedback input.
%
%   [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%   net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%   <a href="matlab:doc view">view</a>(net)
%   Y = net(Xs,Xi,Ai)
%
% Now a delay is removed from the network so that its output is one time
% step ahead of its inputs.
%
%   net = <a href="matlab:doc removedelay">removedelay</a>(net);
%   <a href="matlab:doc view">view</a>(net)
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   Y = net(Xs,Xi,Ai)
%
%  See also REMOVEDELAY, OPENLOOP, CLOSELOOP.

% Copyright 2010 The MathWorks, Inc.

% Format & Check
nnassert.minargs(nargin,1);
if nargin<2, n = 1; end
nntype.network('check',net,'NET');
nntype.int_scalar('check',n,'Number of delays N');

% Check resulting delays will be zero or positive
minInputDelay = NaN;
for i = 1:numel(net.inputConnect)
  if net.inputConnect(i)
    minInputDelay = min([minInputDelay net.inputWeights{i}.delays]);
  end
end
if isfinite(minInputDelay) && ((minInputDelay - n) < 0)
  nnerr.throw('Args',['Removing ' num2str(n) ' to input delays would result in a negative input weight delay.']);
end

% Remove Delays to Input Weights
for i = 1:numel(net.inputConnect)
  if net.inputConnect(i)
    net.inputWeights{i}.delays = net.inputWeights{i}.delays - n;
  end
end

% Add Delays to Feedback Outputs
for i=1:net.numLayers
  if net.outputConnect(i)
    net.outputs{i}.feedbackDelay = net.outputs{i}.feedbackDelay + n;
  end
end

