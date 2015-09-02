classdef nnfcnNetworkInit < nnfcnInfo
%NNNETWORKINITFCNINFO Layer initialization function info.

% Copyright 2010 The MathWorks, Inc.
  
  properties (SetAccess = private)
  end
  
  methods
    
    function x = nnfcnNetworkInit(name,title,version)
      if nargin < 3, error(message('nnet:Args:NotEnough')); end
      
      x = x@nnfcnInfo(name,title,'nntype.network_init_fcn',version);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnNetworkInit">Network Initialization Function Info</a>')
      fprintf('\n')
      disp('            (none)');
    end
    
  end
  
end
