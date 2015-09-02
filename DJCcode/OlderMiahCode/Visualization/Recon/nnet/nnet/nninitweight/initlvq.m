function out1 = initlvq(in1,in2,in3,in4,in5,in6)
%INITLVQ LVQ weight initialization function.
%
%  <a href="matlab:doc initlvq">initlvq</a> initializes the weights of the output layer of an LVQ network.
%
%  <a href="matlab:doc initlvq">initlvq</a>('configure',x) takes inputs X and returns initialization
%  settings for weights associated with that input data.
%
%  <a href="matlab:doc initlvq">initlvq</a>('initialize',net,'IW',i,j,settings) returns new weights
%  for layer i from input j.
%
%  <a href="matlab:doc initlvq">initlvq</a>('initialize',net,'LW',i,j,settings) returns new weights
%  for layer i from layer j.
%
%  <a href="matlab:doc initlvq">initlvq</a>('initialize',net,'b',i) returns new biases for layer i.
%
%  See also LVQNET.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.10.5 $  $Date: 2011/05/09 01:01:23 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Weight/Bias Initialization Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  if ischar(in1)
    switch lower(in1)
      case 'info', out1 = INFO;
      case 'configure'
        out1 = configure_weight(in2);
      case 'initialize'
        switch(upper(in3))
        case {'IW'}
          if INFO.initInputWeight
            if in2.inputConnect(in4,in5)
              out1 = initialize_input_weight(in2,in4,in5,in6);
            else
              out1 = [];
            end
          else
            nnerr.throw([upper(mfilename) ' does not initialize input weights.']);
          end
        case {'LW'}
          if INFO.initLayerWeight
            if in2.layerConnect(in4,in5)
              out1 = initialize_layer_weight(in2,in4,in5,in6);
            else
              out1 = [];
            end
          else
            nnerr.throw([upper(mfilename) ' does not initialize input weights.']);
          end
        case {'B'}
          if INFO.initBias
            if in2.biasConnect(in4)
              out1 = initialize_bias(in2,in4);
            else
              out1 = [];
            end
          else
            nnerr.throw([upper(mfilename) ' does not initialize biases.']);
          end
        otherwise,
          error(message('nnet:Args:UnrecValue'));
        end
      otherwise
        try
          out1 = eval(['INFO.' in1]);
        catch me,
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    if (nargin == 1)
      if INFO.initFromRows
        out1 = new_value_from_rows(in1);
      else
        nnerr.throw([upper(mfilename) ' cannot initialize from rows.']);
      end
    elseif (nargin == 2)
      if numel(in2) == 1
        if INFO.initFromRowsCols
          out1 = new_value_from_rows_cols(in1,in2);
        else
          nnerr.throw([upper(mfilename) ' cannot initialize from rows and columns.']);
        end
      elseif size(in2,2) == 2
        if INFO.initFromRowsRange
          out1 = new_value_from_rows_range(in1,minmax(in2));
        else
          nnerr.throw([upper(mfilename) ' cannot initialize from rows and ranges.']);
        end
      elseif size(in2,2) > 2
        if INFO.initFromRowsInput
          out1 = new_value_from_rows_inputs(in1,minmax(in2));
        else
          nnerr.throw([upper(mfilename) ' cannot initialize from rows and inputs.']);
        end
      else
        error(message('nnet:initlvq:SecondArgNotScalarOr2Col'));
      end
    else
      error(message('nnet:Args:TooManyInputArgs'));
    end
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnWeightInit(mfilename,'LVQ 2nd Layer Weight',7.0,...
    false,false,true,false,false,false,false, false);
end

function settings = configure_weight(inputs)
  settings = struct;
end

function w = initialize_input_weight(net,i,j,config)
  error(message('nnet:NNInit:InitBNotSupported'));
end

function w = initialize_layer_weight(net,i,j,config)
  s1 = net.layers{j}.size;
  s2 = net.layers{i}.size;
  k = nnstring.first_match('lvqoutputs',net.outputs{i}.processFcns);
  if isempty(k)
    classRatios = ones(s2,1)/s2;
  else
    classRatios = net.outputs{i}.processSettings{k}.classRatios;
  end
  classPercents = classRatios / sum(classRatios);
  indices = [0; floor(cumsum(classPercents)*s1)];
  w = zeros(s2,s1);
  for k=1:s2
   w(k,(indices(k)+1):indices(k+1)) = 1;
  end
  
  % TODO - Communicate dependency on LVQOUTPUTS processing function
end

function b = initialize_bias(net,i)
  error(message('nnet:NNInit:InitBNotSupported'));
end

function x = new_value_from_rows(rows)
  error(message('nnet:NNInit:InitRowsNotSupported'));
end

function x = new_value_from_rows_cols(rows,cols)
  error(message('nnet:NNInit:InotRowsColsNotSupported'));
end

function x = new_value_from_rows_range(rows,range)
  error(message('nnet:NNInit:InitRowsRangesNotSupported'));
end

function x = new_value_from_rows_inputs(rows,inputs)
  error(message('nnet:NNInit:InitRowsInputsNotSupported'));
end


