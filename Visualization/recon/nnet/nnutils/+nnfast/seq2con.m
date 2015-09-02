function y = seq2con(x)
%SEQ2CON_FAST

% Copyright 2010 The MathWorks, Inc.


[R,TS] = size(x);
if (TS == 0)
  y = cell(R,0);
else
  y = cell(R,1);
  for i=1:R
    y{i} = [x{i,:}];
  end
end
