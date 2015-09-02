function d = numderivn(fcn,x0,da,maxstep)

% Copyright 2010-2011 The MathWorks, Inc.

if nargin < 4
  maxstep = 100;
end

accuracy = 1e-10;

if nargin < 3
  d = nntest.dnumn(fcn,x0,'maxstep',maxstep);
else
  d = NaN;
  e = inf;
  while (maxstep > 1e-32)
    dc = nntest.dnumn(fcn,x0,'style','central','maxstep',maxstep);
    newe = abs(dc-da);
    if (newe < e)
      d = dc;
      e = newe;
      if (e <= accuracy), return; end
    end
    
    shift = maxstep * 2^-26;
    df = nntest.dnumn(fcn,x0+shift,'style','forward','maxstep',maxstep);
    newe = abs(df-da);
    if (newe < e)
      d = df;
      e = newe;
      if (e <= accuracy), return; end
    end
    db = nntest.dnumn(fcn,x0-shift,'style','backward','maxstep',maxstep);
    newe = abs(db-da);
    if (newe < e)
      d = db;
      e = newe;
      if (e <= accuracy), return; end
    end
    
    dc = (df + db) / 2;
    newe = abs(dc-da);
    if (newe < e)
      d = dc;
      e = newe;
      if (e <= accuracy), return; end
    end
    
    maxstep = maxstep / 4;
  end
end
