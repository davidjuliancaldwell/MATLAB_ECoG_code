function [out1,out2] = pos_inc_int_row(in1,in2,in3)
%NN_POS_INC_INT_ROW Positive increasing integer row type.

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
  info = nnfcnType(mfilename,'Positive Increasing Integer Row',7.0);
end

function err = type_check(x)
  if ~isnumeric(x)
    err = 'VALUE is not numeric.';
  elseif (~isempty(x)) && (size(x,1) ~= 1)
    err = 'VALUE is not a row vector.';
  elseif any(~isfinite(x))
    err = 'VALUE is not finite.';
  elseif any(~isfinite(x) | (x<0))
    err = 'VALUE contains a negative value.';
  elseif any(x ~= round(x))
    err = 'VALUE contains a non-integer value.';
  elseif any(diff(x) == 0)
    err = 'VALUE contains duplicate values.';
  elseif any(diff(x) < 0)
    err = 'VALUE contains out of order values.';
  else
    err = '';
  end
end

function x = strict_format(x)
end
