function [out1,out2] = weight_init_fcn(in1,in2,in3)
%NN_WEIGHT_INIT_FCN Weight or bias initialization function type.

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
  info = nnfcnFunctionType(mfilename,'Weight/Bias Initialization Function',7,...
    7,fullfile('nnet','nninitweight'));
end

function err = type_check(x)
  err = nntest.fcn(x,false);
  % TODO - More here
end

function err = strict_format(fcn)

  % Random stream
  saveRandStream = RandStream.getGlobalStream;
  RandStream.setGlobalStream(RandStream('mt19937ar','seed',pi));
  
  fcn = nntype.modular_fcn('format',fcn);
  
  err = nntest.fcn(fcn,false);
  if ~isempty(err), return; end
  info = feval(fcn,'info');
  if ~strcmp(info.type,'nntype.weight_init_fcn')
    err = [upper(fcn) '(''type'') is not nntype.weight_init_fcn.'];
    return;
  end
  
  info = feval(fcn,'info');
  
  x = mat2cell(rand(4,20),4,[10 10]);
  t = mat2cell(rand(3,20),3,[10 10]);
  net = narxnet(1:2,5);
  net = configure(net,[x;t],t);
  
  if info.initBias
    b = feval(fcn,'initialize',net,'b',1);
  end
  
  if info.initInputWeight
    s = feval(fcn,'configure',net,'IW',1,1);
    w = feval(fcn,'initialize',net,'IW',1,1,s);
  end
  
  if info.initLayerWeight
    s = feval(fcn,'configure',net,'LW',2,1);
    w = feval(fcn,'initialize',net,'LW',2,1,s);
  end
  
  if info.initFromRows
    w = feval(fcn,5);
  end
  
  if info.initFromRowsCols
    w = feval(fcn,5,4);
  end
  
  if info.initFromRowsRange
    w = feval(fcn,rand(4,2));
  end
  
  if info.initFromRowsInput
    w = feval(fcn,rand(4,8));
  end
  
  % Random Stream
  RandStream.setGlobalStream(saveRandStream);
end
