classdef nnfcnNetwork < nnfcnInfo
%NNNETWORKFCNINFO Network function info.

% Copyright 2010 The MathWorks, Inc.
  
  properties (SetAccess = private)
  end
  
  methods
    
    function x = nnfcnNetwork(name,title,version,param)
      if nargin < 3, error(message('nnet:Args:NotEnough')); end
      
      x = x@nnfcnInfo(name,title,'nntype.network_fcn',version);
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnNetwork">Network Initialization Function Info</a>')
      fprintf('\n')
      %=======================:
      disp(['       parameters: ' nnlink.params2str(x.parameters)]);
    end
    
  end
  
end
