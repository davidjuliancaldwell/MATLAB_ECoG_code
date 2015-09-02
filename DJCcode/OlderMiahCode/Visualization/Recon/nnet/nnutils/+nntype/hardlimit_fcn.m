function [out1,out2] = hardlimit_fcn(in1,in2,in3)
%NN_FEEDBACK_MODE Time series output-to-input feedback loop mode.
%
%  This function defines the type: Feedback Mode. Feedback modes represent
%  the state of networks' output-to-input feedback connections.
%
%  A feedback mode can be one of three char arrays: 'open', 'closed', or
%  the empty string ''.
%
%  The empty string '' indicates no feedback loop.
%
%  Open feedback loops are represented by the string 'open'. This
%  represents the situation where a network output is associated
%  with an input.  The output forms a prediction of the input.
%
%  Closed feedback loops are represented by the string 'closed'. This
%  indicates that a network output has feedback to other layers.  The
%  output forms a prediction of an input, which is fed 
%
%  See also NARNET, NARXNET, OPENLOOP, CLOSELOOP, NOLOOP.

% Copyright 2010-2011 The MathWorks, Inc.

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
  info = nnfcnType(mfilename,'String',7.0);
end

function err = type_check(x)
  if ~ischar(x)
    err = 'VALUE is not char.';
  elseif size(x,1) ~= 1
    err = 'VALUE is not a single row char array.';
  elseif isempty(nnstring.first_match(lower(x),{'hardlim','hardlims'}))
    err = 'VALUE is not ''hardlim'' or ''hardlims''.';
  else
    err = '';
  end
end

function x = strict_format(x)
  x = lower(x);
end
