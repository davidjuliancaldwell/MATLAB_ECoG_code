function net = adddelay(net,n)
%ADDDELAY Add a delay to a neural network's response.
%
%  <a href="matlab:doc adddelay">adddelay</a>(NET) returns a network whose output responds one time
%  step later then the original network.
%
%  <a href="matlab:doc adddelay">adddelay</a>(NET,N) returns a network whose response is N time
%  steps later than the original network.
%
%  In both cases, the number of added delays N are implements by adding
%  N to the delays of each input weight.
%  
%  If a network has a feedback output, then N is subtracted from its
%  feedback delay to indicate it generates outputs N steps later
%  than it did before.
%
%  Here a time delay network is created, a delay removed, and then
%  added back into the network.
%
%    net = <a href="matlab:doc timedelaynet">timedelaynet</a>(1:2,10);
%    <a href="matlab:doc view">view</a>(net)
%    net = <a href="matlab:doc removedelay">removedelay</a>(net);
%    <a href="matlab:doc view">view</a>(net)
%    net = <a href="matlab:doc adddelay">adddelay</a>(net);
%    <a href="matlab:doc view">view</a>(net)
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
if isfinite(minInputDelay) && ((minInputDelay + n) < 0)
  nnerr.throw('Args',['Removing ' num2str(n) ' delays would result in a negative input weight delay.']);
end

% Add Delays to Input Weights
for i = 1:numel(net.inputConnect)
  if net.inputConnect(i)
    net.inputWeights{i}.delays = net.inputWeights{i}.delays + n;
  end
end

% Remove Delays from Feedback Outputs
for i=1:net.numLayers
  if net.outputConnect(i)
    net.outputs{i}.feedbackDelay = net.outputs{i}.feedbackDelay - n;
  end
end

