function out1 = midpoint(in1,in2,in3,in4,in5,in6)
%MIDPOINT Midpoint weight initialization function.
%
%  <a href="matlab:doc midpoint">midpoint</a> initializes weight row vectors to the midpoint of their
%  associated input data.  This is useful for initializing networks such
%  as <a href="matlab:doc competlayer">competlayer</a> competitive layers.
%
%  <a href="matlab:doc midpoint">midpoint</a>(S,X) takes the number of neurons S and NxQ input data X
%  and returns SxN weight values, consisting of S copies of the midpoint
%  of input column vectors in X.
%
%  Here initial weight values are calculated for a 5 neuron
%  layer with input elements ranging over [0 1] and [-2 2].
%
%    W = <a href="matlab:doc midpoint">midpoint</a>(5,[0 1; -2 2])
%
%  See also INITWB, INITLAY, INIT.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.4 $  $Date: 2011/02/28 01:28:05 $

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
        error(message('nnet:midpoint:SecondArgNotScalarOr2Col'));
      end
    else
      error(message('nnet:Args:TooManyInputArgs'));
    end
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnWeightInit(mfilename,'Zero',7.0,...
    false,true,true, true,true,true,true, false);
end

function settings = configure_weight(inputs)
  settings.midpoint = safe_midpoint(inputs);
end

function w = initialize_input_weight(net,i,j,config)
  w = repmat(config.midpoint',net.layers{i}.size,1);
end

function w = initialize_layer_weight(net,i,j,config)
  w = repmat(config.midpoint',net.layers{i}.size,1);
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
  x = repmat(safe_midpoint(range)',rows,1);
end

function x = new_value_from_rows_inputs(rows,inputs)
  x = repmat(safe_midpoint(inputs)',size(inputs,1),1);
end

%% SUPPORT FUNCTIONS

function m = safe_midpoint(x)
  m = mean(minmax(x),2);
  m(~isfinite(m)) = 0;
end

