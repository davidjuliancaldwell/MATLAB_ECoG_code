function x=post_inputs(fcns,x)
%POSTPROCESSINPUTS Preprocess inputs.
%
%  POSTPROCESSINPUTS(fcns,x)

% Copyright 2007-2012 The MathWorks, Inc.

for i=1:fcns.numInputs
  x(i,:) = nn7.reverse(fcns.inputs(i).process,x(i,:));
end
