% Neural network output processFcns property.
% 
% NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processFcns">processFcns</a>
%
% This property defines a row cell array of <a href="matlab:doc nnprocess">processing function</a> names to
% be used by the ith network output. The processing functions are applied
% to target values before the network uses them, and applied in reverse to
% layer output values before being returned as network output values.
%
% The <a href="matlab:doc nnprocess">processing functions</a> (net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processFcns">processFcns</a>) and their associated
% processing parameters (net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processParams">processParams</a>) are used to define
% proper settings (net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processSettings">processSettings</a>) during network
% configuration which either happens the first time <a href="matlab:doc train">train</a> is called,
% or by calling <a href="matlab:doc configure">configure</a> directly, to best match the example data.
%
% Then whenever the network is trained or simulated, processing
% occurs consistent with those settings.
%
% Side Effects:
%
% Whenever this property is altered, the output size is set to 0 and the
% processSettings are set accordingly.
%
% See also CONFIGURE, TRAIN, SIM

% Copyright 2010 The MathWorks, Inc.
