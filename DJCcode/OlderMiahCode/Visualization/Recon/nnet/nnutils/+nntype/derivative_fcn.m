function [out1,out2] = derivative_fcn(in1,in2,in3)
%NN_DERIVATIVE_FCN Derivative function type.

% Copyright 2010-2012 The MathWorks, Inc.

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
  info = nnfcnFunctionType(mfilename,'Derivative Function',7,...
    7,fullfile('nnet','nnderivative'));
end

function err = type_check(fcn)
  err = nntest.fcn(fcn,false);
  if ~isempty(err), return; end
  info = feval(fcn,'info');
  if ~strcmp(info.type,'nntype.derivative_fcn')
    err = [upper(fcn) '(''type'') is not nntype.derivative_fcn.'];
    return;
  end
  
  % Random Stream
  rsSave = RandStream.getGlobalStream;
  RandStream.setGlobalStream(RandStream.create('mrg32k3a'));
  
  % Numerical Function
  % Compare every function to NUM5DERIV, except compare
  % NUM5DERIV to NUM2DERIV.
  if strcmp(fcn,'num5deriv')
    numfcn = 'num2deriv';
  else
    numfcn = 'num5deriv';
  end
  
  % Static Data and Network
  x = rand(4,3);
  t = rand(3,3);
  ew = {1}; %rand(size(t));
  net = feedforwardnet(5);
  net = configure(net,x,t);
  
  % Static Gradient Test
  dperf1 = feval(fcn,'dperf_dwb',net,x,t,{},{},ew);
  dperf2 = feval(numfcn,'dperf_dwb',net,x,t,{},{},ew);
  rel_diff = max(max(abs(dperf1-dperf2)))/sqrt(sum(dperf1.*dperf1));
  if rel_diff > 1e-7
    err = [upper(fcn) ' dperf_dwb does not match numerical calculations.'];
    return
  end
  
  % Static Jacobian Test
  de1 = feval(fcn,'de_dwb',net,x,t,{},{},ew);
  de2 = feval(numfcn,'de_dwb',net,x,t,{},{},ew);
  rel_diff = max(max(abs(de1-de2)))/sqrt(sum(sum(de1.*de1)));
  if rel_diff > 1e-7
    err = [upper(fcn) ' de_dwb does not match numerical calculations.'];
    return
  end
  
  % Dynamic Data and Network
  x = mat2cell(rand(2,6),2,2+zeros(1,3));
  t = mat2cell(rand(1,6),1,2+zeros(1,3));
  ew = mat2cell(rand(1,6),1,2+zeros(1,3));
  net = narxnet(1:2,2);
  net = configure(net,[x;t],t);
  [x,xi,ai,t,ew] = preparets(net,x,{},t,ew);
  
  % Dynamic Gradient Test
  dwb1 = feval(fcn,'dperf_dwb',net,x,t,xi,ai,ew);
  dwb2 = feval(numfcn,'dperf_dwb',net,x,t,xi,ai,ew);
  rel_diff = max(max(abs(dwb1-dwb2)))/sqrt(sum(dwb1.*dwb1));
  if rel_diff > 1e-7
    err = [upper(fcn) ' dperf_dwb does not match numerical calculations.'];
    return
  end
  
  % Dynamic Jacobian Test
  de1 = feval(fcn,'de_dwb',net,x,t,xi,ai,ew);
  de2 = feval(numfcn,'de_dwb',net,x,t,xi,ai,ew);
  rel_diff = max(max(abs(de1-de2)))/sqrt(sum(sum(de1.*de1)));
  if rel_diff > 1e-7
    err = [upper(fcn) ' de_dwb does not match numerical calculations.'];
    return
  end
  
  % Random Stream
  RandStream.setGlobalStream(rsSave);
end

function x = strict_format(x)
  x = nntype.modular_fcn('format',x);
end
