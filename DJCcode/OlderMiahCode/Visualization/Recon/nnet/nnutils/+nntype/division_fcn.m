function [out1,out2] = division_fcn(in1,in2,in3)
%NN_DIVISION_FCN Data division function type.

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
  info = nnfcnFunctionType(mfilename,'Data Division Function',7,...
    7,fullfile('nnet','nndivision'));
end

function err = type_check(x)
  err = nntest.fcn(x,false);
  if ~isempty(err), return; end
  info = feval(x,'info');
  if ~strcmp(info.type,'nntype.division_fcn')
    err = [upper(x) '(''type'') is not nntype.division_fcn.'];
    return;
  end
  
  % Random stream
  saveRandStream = RandStream.getGlobalStream;
  RandStream.setGlobalStream(RandStream('mt19937ar','seed',pi));
  
  % Check that indices are returned and all assigned
  if ~strcmp(x,'divideind')
    q = 1205;
    param = feval(x,'defaultParam');
    [i1,i2,i3] = feval(x,q,param);
    ii = sort([i1 i2 i3]);
    if length(ii) ~= q
      err = [upper(x) ' does not return all the indices.'];
      return
    end
    if any(ii ~= 1:q)
      err = [upper(x) ' does not return each index once and only once.'];
      return
    end
  end
  
  % Random Stream
  RandStream.setGlobalStream(saveRandStream);
end

function x = strict_format(x)
end
