function out1 = randtop(varargin)
%RANDTOP Random layer topology function.
%
%  <a href="matlab:doc randtop">randtop</a> calculates the neuron positions for layers whose
%  neurons are arranged in an N dimensional random pattern.
%
%  <a href="matlab:doc randtop">randtop</a>(DIM1,DIM2,...,DIMN) takes N positive integer arguments
%  and returns and NxS matrix of N coordinate vectors, where S is
%  the product of DIM1*DIM2*...*DIMN.
%
%  Here positions are created with this function and plotted.
%
%    positions = <a href="matlab:doc randtop">randtop</a>(8,5);
%    net = <a href="matlab:doc selforgmap">selforgmap</a>([8 5],'topologyFcn','<a href="matlab:doc randtop">randtop</a>');
%    <a href="matlab:doc plotsomtop">plotsomtop</a>(net)
%
%  See also GRIDTOP, HEXTOP.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.6.12 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Topology Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  in1 = varargin{1};
  if ischar(in1)
    switch in1
      case 'info',
        out1 = INFO;
      case 'check_param'
        out1 = '';
      otherwise,
        % Quick info field access
        try
          out1 = eval(['INFO.' in1]);
        catch %#ok<CTCH>
          nnerr.throw(['Unrecognized argument: ''' in1 ''''])
        end
    end
  else
    out1 = calculate_positions(varargin{:});
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

%%
function info = get_info
  info = nnfcnTopology(mfilename,'Random',fcnversion,0);
end

function pos = calculate_positions(varargin)
  dim = [varargin{:}];
  dims = length(dim);
  pos = zeros(dims,prod(dim));

  noiseLen = 0.8;
  noiseElement = (noiseLen^2)/dims;
  noise = (rand(dims,prod(dim))*2-1) * noiseElement;
  hexpos = hextop(varargin{:});
  pos =  (hexpos + noise) * 0.6/noiseLen;
  posmin = min(pos,[],2);
  pos = pos - posmin(:,ones(1,prod(dim)));
end
