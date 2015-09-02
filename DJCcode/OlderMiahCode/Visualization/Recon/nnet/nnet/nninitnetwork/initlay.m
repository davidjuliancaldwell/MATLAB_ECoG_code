function out1=initlay(in1,in2,in3,in4,in5,in6)
%INITLAY Layer-by-layer network initialization function.
%
%  <a href="matlab:doc initlay">initlay</a>(net) takes a neural network and returns it with new initial
%  weight and bias values.
%
%  <a href="matlab:doc initlay">initlay</a> calculates weight and bias values by calling the each ith layer's
%  initialization function, net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_initFcn">initFcn</a>.
%
%  Here is how to setup a network to use layer initialization functions,
%  configure it for particular data, and initialize it.
%
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net.<a href="matlab:doc nnproperty.net_initFcn">initFcn</a> = '<a href="matlab:doc initlay">initlay</a>';
%    net.<a href="matlab:doc nnproperty.net_layers">layers</a>{1}.<a href="matlab:doc nnproperty.layer_initFcn">initFcn</a> = '<a href="matlab:doc initnw">initnw</a>';
%    net.<a href="matlab:doc nnproperty.net_layers">layers</a>{2}.<a href="matlab:doc nnproperty.layer_initFcn">initFcn</a> = '<a href="matlab:doc initnw">initnw</a>';
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = configure(net);
%    net = init(net)
%    net.<a href="matlab:doc nnproperty.net_IW">IW</a>{1,1}, net.<a href="matlab:doc nnproperty.net_b">b</a>{1}
%    net.<a href="matlab:doc nnproperty.net_LW">LW</a>{2,1}, net.<a href="matlab:doc nnproperty.net_b">b</a>{2}
%
%  See also INITNW, INITLAY, INIT.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.4 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Network Initialization Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  if ischar(lower(in1))
    switch in1
      case 'configure'
        switch upper(in3)
          case 'IW'
            if in2.inputConnect(in4,in5)
              out1 = configure_input_weight(in2,in4,in5,in6);
            else
              out1 = in2;
            end
          case 'LW'
            if in2.layerConnect(in4,in5)
              out1 = configure_layer_weight(in2,in4,in5,in6);
            else
              out1 = in2;
            end
          otherwise
            error(message('nnet:Args:UnrecInputArrangement'));
        end
      case 'initialize'
        switch upper(in3)
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
            error(message('nnet:Args:UnrecInputArrangement'));
        end
      case 'info'
        out1 = INFO;
      case 'check_param'
        out1 = '';
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, 
          nnerr.throw('Unsupported',['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    out1 = initialize_network(in1);
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
 info = nnfcnNetworkInit(mfilename,'Layer-by-Layer',fcnversion);
end

function settings = configure_input_weight(net,i,j,x)
  initFcn = net.layers{i}.initFcn;
  if isempty(initFcn)
    settings = struct;
  else
    settings = feval(initFcn,'configure',net,'IW',i,j,x);
  end
end

function settings = configure_layer_weight(net,i,j,x)
  initFcn = net.layers{i}.initFcn;
  if isempty(initFcn)
    settings = struct;
  else
    settings = feval(initFcn,'configure',net,'LW',i,j,x);
  end
end

function net = initialize_input_weight(net,i,j)
  initFcn = net.layers{i}.initFcn;
  if ~isempty(initFcn)
    net = feval(initFcn,'initialize',net,'IW',i,j,net.inputWeights{i,j}.initSettings);
  end
end

function net = initialize_layer_weight(net,i,j)
  initFcn = net.layers{i}.initFcn;
  if ~isempty(initFcn)
    net = feval(initFcn,'initialize',net,'LW',i,j,net.layerWeights{i,j}.initSettings);
  end
end

function net = initialize_bias(net,i)
  initFcn = net.layers{i}.initFcn;
  if ~isempty(initFcn)
    net = feval(initFcn,'initialize',net,'b',i);
  end
end

function net = initialize_network(net)
  for i=1:net.numLayers
    initFcn = net.layers{i}.initFcn;
    if ~isempty(initFcn)
      net = feval(initFcn,net,i);
    end
  end
end

