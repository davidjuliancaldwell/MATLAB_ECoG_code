function setdemorandstream(n)
%SETDEMORANDOMSTREAM Set default stream for reliable example results.
%
%  SETDEMORANDOMSTREAM(N) is less distracting in example code, but
%  equivalent to:
%
%    rs = RandStream('mcg16807','Seed',n);
%    RandStream.setGlobalStream(rs);

% Copyright 2011-2012 The MathWorks, Inc.

rs = RandStream('mcg16807','Seed',n);
RandStream.setGlobalStream(rs);
