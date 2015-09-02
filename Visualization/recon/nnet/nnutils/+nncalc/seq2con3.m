function y = seq2con3(x)
%SEQ2CON3 Convert 3D cell array of sequential vectors to concurrent vectors.
%
%  Y = SEQ2CON(X)

% Copyright 2010-2012 The MathWorks, Inc.

[R,C,TS] = size(x);
if (TS == 0)
  y = cell(R,C,0);
else
  y = cell(R,C);
  for i=1:R
    for j=1:C
      y{i,j} = [x{i,j,:}];
    end
  end
end
