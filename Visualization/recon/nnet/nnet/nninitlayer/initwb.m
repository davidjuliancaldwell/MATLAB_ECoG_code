function out1=initwb(in1,in2,in3,in4,in5,in6)
%INITWB By-weight-and-bias layer initialization function.
%
%  <a href="matlab:doc initwb">initwb</a>(net,i) returns a network with layer i's weights and biases
%  initialized to new values.
%
%  <a href="matlab:doc initwb">initwb</a> calculates weight initialization settings and weight and bias
%  values by calling the individual weight and bias initialization
%  functions.
%
%  Here is how to setup a network to use layer initialization functions and
%  a particular layer i to use individual weight/bias functions, configure
%  a network for particular data, and then initialize it.
%
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net.<a href="matlab:doc nnproperty.net_initFcn">initFcn</a> = '<a href="matlab:doc initlay">initlay</a>';
%    net.<a href="matlab:doc nnproperty.net_layers">layers</a>{1}.<a href="matlab:doc nnproperty.layer_initFcn">initFcn</a> = '<a href="matlab:doc initwb">initwb</a>';
%    net.<a href="matlab:doc nnproperty.net_layers">layers</a>{2}.<a href="matlab:doc nnproperty.layer_initFcn">initFcn</a> = '<a href="matlab:doc initwb">initwb</a>';
%    net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{1,1}.<a href="matlab:doc nnproperty.weight_initFcn">initFcn</a>
%    net.<a href="matlab:doc nnproperty.net_biases">biases</a>{1}.<a href="matlab:doc nnproperty.bias_initFcn">initFcn</a>
%    net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{2,1}.<a href="matlab:doc nnproperty.weight_initFcn">initFcn</a>
%    net.<a href="matlab:doc nnproperty.net_biases">biases</a>{2}.<a href="matlab:doc nnproperty.bias_initFcn">initFcn</a>
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc configure">configure</a>(net,x,t);
%    net = init(net)
%    net.<a href="matlab:doc nnproperty.net_IW">IW</a>{1,1}, net.<a href="matlab:doc nnproperty.net_b">b</a>{1}
%    net.<a href="matlab:doc nnproperty.net_LW">LW</a>{2,1}, net.<a href="matlab:doc nnproperty.net_b">b</a>{2}
%
%  See also INITNW, INITLAY, INIT.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.10.6 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Layer Initialization Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), nnerr.throw('Unsupported',nn_TooFewInp); end
  if ischar(in1)
    switch in1
      case 'configure'
        switch(upper(in3))
          case 'IW'
            if in2.inputConnect(in4,in5)
              out1 = configure_input_weight(in2,in4,in5,in6);
            else
              out1 = [];
            end
          case 'LW'
            if in2.layerConnect(in4,in5)
              out1 = configure_layer_weight(in2,in4,in5,in6);
            else
              out1 = [];
            end
          otherwise
            error(message('nnet:NNet:UnrecWeightType'));
        end
      case 'initialize'
        switch(upper(in3))
          case 'IW'
            if in2.inputConnect(in4,in5)
              out1 = initialize_input_weight(in2,in4,in5);
            else
              out1 = [];
            end
          case 'LW'
            if in2.layerConnect(in4,in5)
              out1 = initialize_layer_weight(in2,in4,in5);
            else
              out1 = [];
            end
          case 'B'
            if in2.biasConnect(in4)
              out1 = initialize_bias(in2,in4);
            else
              out1 = [];
            end
          otherwise
            error(message('nnet:Args:UnrecValue'));
        end
      case 'info'
        out1 = INFO;
      case 'check_param'
        out1 = '';
      otherwise
        try
          out1 = eval(['INFO.' in1]);
        catch me
          nnerr.throw(['Unrecognized argument: ''' in1 ''''])
        end
    end
  else
    if (nargin < 2), nnerr.throw('Unsupported',nn_TooFewInp); end
    out1 = initialize_layer(in1,in2);
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnLayerInit(mfilename,'Weight-and-Bias',7.0);
end

function settings = configure_input_weight(net,i,j,x)
  initFcn = net.inputWeights{i,j}.initFcn;
  if ~isempty(initFcn)
    settings = feval(net.inputWeights{i,j}.initFcn,'configure',x);
  else
    settings = struct;
  end
end

function settings = configure_layer_weight(net,i,j,x)
  initFcn = net.layerWeights{i,j}.initFcn;
  if ~isempty(initFcn)
    settings = feval(net.layerWeights{i,j}.initFcn,'configure',x);
  else
    settings = struct;
  end
end

function net = initialize_input_weight(net,i,j)
  initFcn = net.inputWeights{i,j}.initFcn;
  if ~isempty(initFcn)
    net.IW{i,j} = feval(initFcn,'initialize',...
      net,'IW',i,j,net.inputWeights{i,j}.initSettings);
  end
end

function net = initialize_layer_weight(net,i,j)
  initFcn = net.layerWeights{i,j}.initFcn;
  if ~isempty(initFcn)
    net.LW{i,j} = feval(initFcn,'initialize',...
      net,'LW',i,j,net.layerWeights{i,j}.initSettings);
  end
end

function net = initialize_bias(net,i)
  initFcn = net.biases{i}.initFcn;
  if ~isempty(initFcn)
    net.b{i} = feval(initFcn,'initialize',net,'b',i);
  end
end

function net = initialize_layer(net,i)
  % Bias
  if net.biasConnect(i)
    initFcn = net.biases{i}.initFcn;
    if ~isempty(initFcn)
      net.b{i} = feval(initFcn,'initialize',net,'b',i);
    end
  end
  % Input weights
  for j=find(net.inputConnect(i,:))
    initFcn = net.inputWeights{i,j}.initFcn;
    if ~isempty(initFcn)
      net.IW{i,j} = feval(initFcn,'initialize',net,'IW',i,j,...
        net.inputWeights{i,j}.initSettings);
    end
  end
  % Layer weights
  for j=find(net.layerConnect(i,:))
    initFcn = net.layerWeights{i,j}.initFcn;
    if ~isempty(initFcn)
      net.LW{i,j} = feval(initFcn,'initialize',net,'LW',i,j,...
        net.layerWeights{i,j}.initSettings);
    end
  end
end
