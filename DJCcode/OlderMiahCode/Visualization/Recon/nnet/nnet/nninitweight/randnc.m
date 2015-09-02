function out1 = randnc(in1,in2,in3,in4,in5,in6)
%RANDNC Normalized column weight initialization function.
%
%  <a href="matlab:doc randnc">randnc</a> initializes weights with random normalized columns.
%
%  <a href="matlab:doc randnc">randnc</a>(S,R) takes the number of neurons (rows) and number of input
%  elements (columns) and returns an SxR matrix of random signed values
%  with columns normalized to a length of 1.
%
%  Here initial weights are calculated for a 5 neuron layer from a
%  3 element input.
%
%    w = <a href="matlab:doc randnc">randnc</a>(5,3)
%  
%  See also RANDNR.

% Mark Beale, 1-31-92
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.4 $  $Date: 2011/02/28 01:28:06 $

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
        error(message('nnet:randnc:SecondArgNotScalarOr2Col'));
      end
    else
      error(message('nnet:Args:TooManyInputArgs'));
    end
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnWeightInit(mfilename,'Random Normalized Column',7.0,...
    false,true,true, true,true,true,true, true);
end

function settings = configure_weight(inputs)
  settings.inputSize = size(inputs,1);
end

function w = initialize_input_weight(net,i,j,config)
  w = normc(rands(net.layers{i}.size,config.inputSize));
end

function w = initialize_layer_weight(net,i,j,config)
  w = normc(rands(net.layers{i}.size,config.inputSize));
end

function b = initialize_bias(net,i)
  b = normc(rands(net.layers{i}.size,1));
end

function x = new_value_from_rows(rows)
  x = normc(rands(rows,1));
end

function x = new_value_from_rows_cols(rows,cols)
  x = normc(rands(rows,cols));
end

function x = new_value_from_rows_range(rows,range)
  x = normc(rands(rows,size(range,1)));
end

function x = new_value_from_rows_inputs(rows,inputs)
  x = normc(rands(rows,size(inputs,1)));
end
