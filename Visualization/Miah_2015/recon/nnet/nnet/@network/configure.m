function net = configure(net,in2,in3,in4)
%CONFIGURE Configure neural network inputs and outputs.
%
%  <a href="matlab:doc configure">configure</a>(NET,X,T) configures network inputs and outputs
%  based on input data X and target data T, preparing the network for
%  best performance when trained on that or similar input and target data.
%
%  Commonly a network creation function will return a network with
%  an unconfigured input and/or output.  (These unconfigured inputs and
%  outputs are indicated by there size being set to 0.) The first time
%  TRAIN is called with an unconfigured network, it will automatically
%  configure it based on the training data.  Alternatively, users may
%  call this function directly before training, or after training to
%  prepare the network to be retrained on different data.
%
%  Inputs and outputs can also be configured individually as follows:
%
%  <a href="matlab:doc configure">configure</a>(net,inputs) configures inputs only.
%  <a href="matlab:doc configure">configure</a>(net,'inputs',inputs) also configures inputs only.
%  <a href="matlab:doc configure">configure</a>(net,'outputs',targets) configures outputs only.
%  <a href="matlab:doc configure">configure</a>(net,'inputs',inputs,i) configures net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.
%  <a href="matlab:doc configure">configure</a>(net,'outputs',targets,i) configures net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i} 
%
%  For example:
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    <a href="matlab:doc view">view</a>(net)
%    net = <a href="matlab:doc configure">configure</a>(net,x,t);
%    <a href="matlab:doc view">view</a>(net)
%
%  See also ISCONFIGURED, UNCONFIGURE, INIT, TRAIN, VIEW.

% Copyright 2010-2012 The MathWorks, Inc.

%  ============ FOR FUNCTION PAGE ==============
%
%  When  input i is configured with data X, properties for input i and
%  input weights associated with input i are set to values which will
%  result in best performance when training with input data X.
%
%  The properties of a network input i (net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}) is
%  configured as follows:
%
%  - The input's .size and .range properties set to match X.
%  - X is processed according to each function in .processFcns,
%    with the associated parameters in .processParams.  The
%    resulting settings are stored in .processSettings so that
%    inputs can be processed consistently by TRAIN, SIM, etc.
%  - The input's .processedSize and .processedRange are set to
%    match the processed X.
%
%  The properties of input weight (net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i,j}) from input j
%  to layer i are configured as follows:
%
%  - The weight's .size is set according to the dimensions of input j.
%  - The weight's .initSettings are configured by the .initFcn
%    according to the processed X.
%
%  When  output i is configured with data T, properties for output i,
%  the layer and layer weights associated with output i are set to values
%  which will result in best performance when training with target data T.
%
%  The properties of each network output (net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}) are
%  configured as follows:
%
%  - The output's .size and .range properties are set to match T.
%  - T is processed according to each function in .processFcns,
%    with the associated parameters in .processParams.  The
%    resulting settings are stored in .processSettings.
%  - The output's .processedSize and processedRange are set to
%    match the processed X.
%
%  The properties of each layer weight from layer j to output
%  layer i are configured as follows:
%
%  - The weight's .size is set according to the dimensions of output i.
%  - The weight's .initSettings are configured by the .initFcn
%    according to the processed T.
%
%  All weight and bias values of the network are autmoatically initialized
%  with INIT each time this function is called.

% Convert from Network to Struct
net = struct(net);

if nargin < 2
  error(message('nnet:Args:NotEnough'));
elseif nargin == 2

  % configure(net,x)
  [x,err] = nntype.data('format',in2);
  if ~isempty(err),nnerr.throw(nnerr.value(err,'Input data')); end
  S = nnfast.numsignals(x);
  if S ~= net.numInputs
    error(message('nnet:NNet:InputNumMismatch'));
  end
  xi = 1:net.numInputs;
  t = {};
  ti = [];

elseif (nargin == 3) && ~ischar(in2)

  % configure(net,x,t)
  [x,err] = nntype.data('format',in2);
  if ~isempty(err),nnerr.throw(nnerr.value(err,'Input data')); end
  [t,err] = nntype.data('format',in3);
  if ~isempty(err),nnerr.throw(nnerr.value(err,'Target data')); end
  numInputs = nnfast.numsignals(x);
  if numInputs ~= net.numInputs
    error(message('nnet:NNet:InputNumMismatch'));
  end
  xi = 1:numInputs;
  numOutputs = nnfast.numsignals(t);
  if numOutputs ~= net.numOutputs
    error(message('nnet:NNet:TargetNumMismatch'));
  end
  ti = 1:numOutputs;

elseif nnstring.first_match(lower(in2),{'input','inputs'})

  % configure(net,'inputs',x) -or- (net,'inputs',x,xi)
  [x,err] = nntype.data('format',in3);
  if ~isempty(err),nnerr.throw(nnerr.value(err,'Input data')); end
  numInputs = nnfast.numsignals(x);
  if nargin < 4
    if numInputs ~= net.numInputs
      error(message('nnet:NNet:InputNumMismatch'));
    end
    xi = 1:numInputs;
  else
    xi = in4;
    err = nntype.index_row_unique('check',in4);
    if ~isempty(err), nnerr.throw(nnerr.value(err,'Indices')); end
    if max(xi) > net.numInputs
      error(message('nnet:NNet:InputIndexOutOfRange'));
    end
    if length(xi) ~= numInputs
      error(message('nnet:NNData:NumIndicesSignalsMismatch'));
    end
  end
  t = {};
  ti = [];

elseif nnstring.first_match(lower(in2),{'output','outputs','target','targets'})

  % configure(net,'outputs',t) or (net,'outputs',t,ti)
  [t,err] = nntype.data('format',in3);
  if ~isempty(err),nnerr.throw(nnerr.value(err,'Target data')); end
  numOutputs = nnfast.numsignals(t);
  if nargin < 4
    if numOutputs ~= net.numOutputs
      error(message('nnet:NNet:TargetNumMismatch'));
    end
    ti = 1:numOutputs;
  else
    ti = in4;
    err = nntype.index_row_unique('check',ti);
    if ~isempty(err), nnerr.throw(nnerr.value(err,'Indices')); end
    if max(ti) > net.numOutputs
      error(message('nnet:NNet:TargetIndexOutOfRange'));
    end
    if length(ti) ~= numOutputs
      error(message('nnet:NNet:IndicesTargetsMismatch'));
    end
  end
  x = {};
  xi = [];

elseif ischar(in2)
  error(message('nnet:Args:Unrec'));
else
  error(message('nnet:Args:Unrec'));
end

net = struct(net);

% Ensure all values are double
for i=1:numel(x), x{i} = double(x{i}); end
for i=1:numel(t), t{i} = double(t{i}); end

% Expand Input, Target
X = cell(net.numInputs,1);
for z=1:length(xi)
  i = xi(z);
  X{i} = [x{z,:}];
end
T = cell(net.numOutputs,1);
for z=1:length(ti)
  i = ti(z);
  T{i} = [t{z,:}];
end

% Input/Output Feedback Consistency
layers2output = cumsum(net.outputConnect);
Xi = false(1,net.numInputs);
Xi(xi) = true;
Ti = false(1,net.numOutputs);
Ti(ti) = true;
for i = 1:net.numInputs
  j = net.inputs{i}.feedbackOutput;
  if ~isempty(j)
    k = layers2output(j);
    if Xi(i) || Ti(k)
      X{i} = [X{i} T{k}];
      T{k} = X{i};
      Xi(i) = true;
      Ti(k) = true;
    end
  end
end
xi = find(Xi);
ti = find(Ti);

% Configure
for i = xi
  net = nn_configure_input(net,i,X{i});
end
outputs2layers = find(net.outputConnect);
for i=ti
  ii = outputs2layers(i);
  net = nn_configure_output(net,ii,T{i});
end
net = nnupdate.read_only_values(net);
net = network(net);
net = init(net);

