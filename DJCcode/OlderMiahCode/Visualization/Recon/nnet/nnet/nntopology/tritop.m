function out1 = tritop(varargin)
%TRITOP Triangle layer topology function.
%
%  <a href="matlab:doc tritop">tritop</a> calculates the neuron positions for layers whose
%  neurons are arranged in a N dimensional triangular pattern.
%
%  <a href="matlab:doc tritop">tritop</a>(DIM1,DIM2,...,DIMN) takes N positive integer arguments
%  and returns and NxS matrix of N coordinate vectors, where S is
%  the product of DIM1*DIM2*...*DIMN.
%
%  Here positions are created with this function and plotted.
%
%    positions = <a href="matlab:doc tritop">tritop</a>(8,5);
%    net = <a href="matlab:doc selforgmap">selforgmap</a>([8 5],'topologyFcn','<a href="matlab:doc tritop">tritop</a>');
%    <a href="matlab:doc plotsomtop">plotsomtop</a>(net)
%
%  See also GRIDTOP, RANDTOP, HEXTOP.

% Mark Beale, 11-31-97
% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.10.6 $

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
  info = nnfcnTopology(mfilename,'Triangular',fcnversion,3);
end

function pos = calculate_positions(varargin)

  dim = [varargin{:}];
  dims = length(dim);
  pos = zeros(dims,prod(dim));
  
  % 1D
  % dx = 1;
  
  % 2D
  % dx = sin(pi/3);
  % dy = cos(pi/3);

  len = 1;
  pos(1,1) = 0;
  center = [];
  for i=1:length(dim)
    dimi = dim(i);
    newlen = len*dimi;
    offset = sqrt(1-sum(sum(center.*center)));

    if (i>1)
      for j=2:dimi
        iShift = center * rem(j+1,2);
      doShift = iShift(:,ones(1,len));
        pos(1:(i-1),(1:len)+len*(j-1)) = pos(1:(i-1),1:len) + doShift;
      end
    end

    posi = (0:(dimi-1))*offset;
    pos(i,1:newlen) = posi(floor((0:(newlen-1))/len)+1);

    len = newlen;
    center = ([center; 0]*i + [center; offset])/(i+1);
  end
end
