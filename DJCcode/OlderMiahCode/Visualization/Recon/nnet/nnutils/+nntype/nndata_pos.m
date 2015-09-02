function [out1,out2] = nndata_pos(in1,in2,in3)
%NNTYPE_NNDATA_POS Neural network data with positive values only.

% Copyright 2010 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Type Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if nargin < 1, error(message('nnet:Args:NotEnough')); end
  if ischar(in1)
    switch (in1)
      
      case 'info'
        % this('info')
        out1 = INFO;
        
      case 'isa'
        % this('isa',value)
        out1 = isempty(type_check(in2));
        
      case {'check','assert','test'}
        % [*err] = this('check',value,*name)
        nnassert.minargs(nargin,2);
        if nargout == 0
          err = type_check(in2);
        else
          try
            err = type_check(in2);
          catch me
            out1 = me.message;
            return;
          end
        end
        if isempty(err)
          if nargout>0,out1=''; end
          return;
        end
        if nargin>2, err = nnerr.value(err,in3); end
        if nargout==0, err = nnerr.value(err,'Value'); end
        if nargout > 0
          out1 = err;
        else
          throwAsCaller(MException(nnerr.tag('Type',2),err));
        end
        
      case 'format'
        % [x,*err] = this('format',x,*name)
        err = type_check(in2);
        if isempty(err)
          out1 = strict_format(in2);
          if nargout>1, out2=''; end
          return
        end
        out1 = in2;
        if nargin>2, err = nnerr.value(err,in3); end
        if nargout < 2, err = nnerr.value(err,'Value'); end
        if nargout>1
          out2 = err;
        else
          throwAsCaller(MException(nnerr.tag('Type',2),err));
        end
        
      case 'check_param'
        out1 = '';
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    error(message('nnet:Args:Unrec1'))
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnType(mfilename,'NN Data',7.0);
end

function err = type_check(x)
  if iscell(x)
    err = nntype.cell_data('check',x);
    if isempty(err)
      [rows,cols] = size(x);
      for i=1:rows
        for j=1:cols
          if any(x{i,j} < 0)
            err = ['VALUE{' num2str(i) ',' num2str(j) ' contains negative values.'];
            return;
          end
        end
      end
    end
  elseif isnumeric(x) || islogical(x)
    err = nntype.matrix_data('check',x);
    if isempty(err)
      if any(x < 0)
        err = 'VALUE constraints negative values.';
      end
    end
  else
    err = 'VALUE is not a matrix or cell array.';
  end
end

function x = strict_format(x)
  x = nntype.data('format',x);
end
