function x=pre_inputs(fcns,x)
%PREPROCESSINPUTS Preprocess inputs.
%
%  PREPROCESSINPUTS(fcns,x)

% Copyright 2007-2012 The MathWorks, Inc.

if ~isempty(x)
  TS = size(x,2);
  Q = size(x{1},2);
  for i=1:fcns.numInputs
    pfcns = nnproc.active_fcns(fcns.inputs(i).process);
    xi = [x{i,:}];
    for k = 1:length(pfcns)
      xi = pfcns(k).apply(xi,pfcns(k).settings);
    end
    x(i,:) = mat2cell(xi,size(xi,1),zeros(1,TS)+Q);
  end
end
