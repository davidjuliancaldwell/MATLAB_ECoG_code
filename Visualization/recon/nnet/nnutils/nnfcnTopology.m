classdef nnfcnTopology < nnfcnInfo
%NNTOPOLOGYFCNINFO Topology function info.

% Copyright 2010 The MathWorks, Inc.

  properties (SetAccess = private)
    symmetry = 0;
  end
  
  methods
    
    function x = nnfcnTopology(name,title,version, ...
        symmetry)
      
      if nargin < 4, error(message('nnet:Args:NotEnough')); end
      if ~nntype.pos_int_scalar('isa',symmetry)
        error(message('nnet:nnfcnTopology:Symmetry'));
      end
      
      x = x@nnfcnInfo(name,title,'nntype.topology_fcn',version);
      x.symmetry = symmetry;
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnDivisionFunctionInfo">nnDivisionFunctionInfo</a>')
      fprintf('\n')
      %=======================:
      disp(['         symmetry: ' nnstring.num2str(x.symmetry)]);
    end
    
  end
  
end

function s = params2str(p)
  n = length(p);
  if n == 0
    s = '(none)';
  else
    s = ['[1x' num2str(n) ' <a href="matlab:doc nnetParamInfo">nnetParamInfo</a> array]'];
  end
end
