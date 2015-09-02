function y = tapdelay(x,signal,timestep,delays,qq)

% Copyright 2010 The MathWorks, Inc.

if nargin < 5
  y = cat(1,x{signal,timestep-delays});
else
  numDelays = length(delays);
  y = cell(1,numDelays);
  for d=1:numDelays
    y{d} = x{signal,timestep-delays(d)}(:,qq);
  end
  y = cat(1,y{:});
end

