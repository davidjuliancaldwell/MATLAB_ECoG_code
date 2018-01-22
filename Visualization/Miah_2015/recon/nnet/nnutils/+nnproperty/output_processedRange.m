% Neural network output processedRange property.
% 
% NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processedRange">processedRange</a>
%
% This property defines the minimum and maximum values of the target data
% used to configure the output, after processing.
%
% The <a href="matlab:doc nnprocess">processing functions</a> (net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processFcns">processFcns</a>) and their associated
% processing parameters (net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processParams">processParams</a>) are used to define
% proper settings (net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processSettings">processSettings</a>) during network
% configuration which either happens the first time <a href="matlab:doc train">train</a> is called,
% or by calling <a href="matlab:doc configure">configure</a> directly, to best match the example data.
%
% Then whenever the network is trained or simulated, processing
% occurs consistent with those settings.

% Copyright 2010 The MathWorks, Inc.
