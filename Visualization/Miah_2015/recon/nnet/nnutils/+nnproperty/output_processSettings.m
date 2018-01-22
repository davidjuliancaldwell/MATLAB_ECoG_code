% Neural network output processSettings property.
% 
% NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processSettings">processSettings</a>
%
% This property holds a row cell array of processing function settings to
% be used by ith network output.
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
% For a list of processing functions, type
%
%   help nnprocess
%
% See also CONFIGURE, TRAIN, SIM

% Copyright 2010 The MathWorks, Inc.
