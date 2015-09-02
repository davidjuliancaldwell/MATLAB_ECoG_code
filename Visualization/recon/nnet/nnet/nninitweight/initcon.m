function out1 = initcon(in1,in2,in3,in4,in5,in6)
%INITCON Conscience bias initialization function.
%  
%  <a href="matlab:doc initcon">initcon</a> is a bias initialization function that initializes
%  biases for learning with the <a href="matlab:doc learncon">learncon</a> learning function.
%
%  <a href="matlab:doc initcon">initcon</a>(S) takes the number of neurons S and returns an Sx1 bias vector.
%
%  Here initial bias values are calculated a 5 neuron layer.
%
%      b = <a href="matlab:doc initcon">initcon</a>(5)
%
%  See also INITWB, INITLAY, INIT, LEARNCON.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.4 $

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
        error(message('nnet:initcon:SecondArgNotScalarOr2Col'));
      end
    else
      error(message('nnet:Args:TooManyInputArgs'));
    end
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnWeightInit(mfilename,'Conscience',7.0,...
    true,false,false, true,true,true,true, false);
end

function settings = configure_weight(inputs)
  settings = struct;
end

function w = initialize_input_weight(net,i,j,config)
  error(message('nnet:NNInit:InitIWNotSupported'));
end

function w = initialize_layer_weight(net,i,j,config)
  error(message('nnet:NNInit:InitLWNotSupported'));
end

function b = initialize_bias(net,i)
  b = new_value_from_rows(net.layers{i}.size);
end

function x = new_value_from_rows(rows)
  c = ones(rows,1)/rows;
  x = exp(1 - log(c));
end

function x = new_value_from_rows_cols(rows,cols)
  x = new_value_from_rows(rows);
end

function x = new_value_from_rows_range(rows,range)
  x = new_value_from_rows(rows);
end

function x = new_value_from_rows_inputs(rows,input)
  x = new_value_from_rows(rows);
end

