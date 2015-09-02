function [out1,out2] = pos_int_scalar(in1,in2,in3)
%NN_POS_INT_SCALAR Positive integer scalar type.
%
%  This function defines the type: Positive integer scalar.
%
%  FLAG = NN_POS_INT_SCALAR('isa',VALUE) returns true if VALUE is
%  a valid value of this type.
%
%  NN_POS_INT_SCALAR('check',VALUE) generates an error if VALUE
%  is not of this type.
%
%  ERRMSG = NN_POS_INT_SCALAR('check',VALUE) returns an error message
%  if value is not of this type.
%
%  Get info about this type function: 
%   info = nntype.pos_int_scalar('info')

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
  info = nnfcnType(mfilename,'Positive Integer',7.0);
end

function err = type_check(x)
  if ~(isnumeric(x) || islogical(x))
    err = 'VALUE is not numeric.';
  elseif numel(x) ~= 1
    err = 'VALUE is not scalar.';
  elseif ~isfinite(x)
    err = 'VALUE is not finite.';
  elseif ~islogical(x) && (x ~= round(x))
    err = 'VALUE is not an integer.';
  elseif (x < 0)
    err = 'VALUE is not 0 or positive.';
  else
    err = '';
  end
end

function x = strict_format(x)
  x = double(x);
end
