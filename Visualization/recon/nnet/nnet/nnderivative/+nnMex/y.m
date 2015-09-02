function [Y,Af] = y(net,data,hints)

if nargout == 2
  [Y,Af] = nnMex.yy(net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.Q,data.TS,hints);
else
  Y = nnMex.yy(net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.Q,data.TS,hints);
end

Y = mat2cell(Y,hints.output_sizes,ones(1,data.TS)*data.Q);
if nargout >= 2
  Af = mat2cell(Af,hints.layer_sizes,ones(1,hints.numLayerDelays)*data.Q);
end
