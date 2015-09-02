classdef nnfcnWeightInit < nnfcnInfo
%NNLAYERINITFCNINFO Weight/bias initialization function info.

% Copyright 2010 The MathWorks, Inc.
  
  properties
    initBias = true;
    initInputWeight = true;
    initLayerWeight = true;
    initFromRows = true;
    initFromRowsCols = true;
    initFromRowsRange = true;
    initFromRowsInput = true;
    irregularWeights = false;
  end
  
  methods
    
    function x = nnfcnWeightInit(name,title,version,b,iw,lw,ir,irc,irr,iri,irw)
      if nargin < 6, error(message('nnet:Args:NotEnough')); end
      
      if ~nntype.bool_scalar('isa',b),error(message('nnet:nnfcnWeightInit:InitB')); end
      if ~nntype.bool_scalar('isa',iw),error(message('nnet:nnfcnWeightInit:InitIW')); end
      if ~nntype.bool_scalar('isa',lw),error(message('nnet:nnfcnWeightInit:InitLW')); end
      if ~nntype.bool_scalar('isa',ir),error(message('nnet:nnfcnWeightInit:InitFromRows')); end
      if ~nntype.bool_scalar('isa',irc),error(message('nnet:nnfcnWeightInit:InitFromRCRows')); end
      if ~nntype.bool_scalar('isa',irr),error(message('nnet:nnfcnWeightInit:InitFromRR')); end
      if ~nntype.bool_scalar('isa',iri),error(message('nnet:nnfcnWeightInit:InitFromRI')); end
      if ~nntype.bool_scalar('isa',irw),error(message('nnet:nnfcnWeightInit:IrrW')); end
      
      x = x@nnfcnInfo(name,title,'nntype.weight_init_fcn',version);
      
      x.initBias = b;
      x.initInputWeight = iw;
      x.initLayerWeight = lw;
      x.initFromRows = ir;
      x.initFromRowsCols = irc;
      x.initFromRowsRange = irr;
      x.initFromRowsInput = iri;
      x.irregularWeights = irw;
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnWeightInit">Weight/Bias Initialization Function Info</a>')
      fprintf('\n')
      %=======================:
      disp(['         initBias: ' nnstring.bool2str(x.initBias)]);
      disp(['  initInputWeight: ' nnstring.bool2str(x.initInputWeight)]);
      disp(['  initLayerWeight: ' nnstring.bool2str(x.initLayerWeight)]);
      disp([     'initFromRows: ' nnstring.bool2str(x.initFromRows)]);
      disp([ 'initFromRowsCols: ' nnstring.bool2str(x.initFromRowsCols)]);
      disp(['initFromRowsRange: ' nnstring.bool2str(x.initFromRowsRange)]);
      disp(['initFromRowsInput: ' nnstring.bool2str(x.initFromRowsInput)]);
      disp([ 'irregularWeights: ' nnstring.bool2str(x.irregularWeights)]);
    end
    
  end
  
end

