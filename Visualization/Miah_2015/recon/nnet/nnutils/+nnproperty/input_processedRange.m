% Neural network input processedRange property.
% 
% NET.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_processedRange">processedRange</a>
%
% This property defines the minimum and maximum values of the input data
% used to configure the input, after processing.
%
% The <a href="matlab:doc nnprocess">processing functions</a> (net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_processFcns">processFcns</a>) and their associated
% processing parameters (net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_processParams">processParams</a>) are used to define
% proper processing settings (net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_processSettings">processSettings</a>) during network
% configuration which either happens the first time <a href="matlab:doc train">train</a> is called, or by
% calling <a href="matlab:doc configure">configure</a> directly, so as to best match the example data.
%
% Then whenever the network is trained or simulated, processing
% occurs consistent with those settings.
%
% See also CONFIGURE

% Copyright 2010 The MathWorks, Inc.
