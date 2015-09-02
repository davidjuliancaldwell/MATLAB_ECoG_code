% Neural network input processFcns property.
% 
% NET.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_processFcns">processFcns</a>
%
% This property defines a row cell array of <a href="matlab:doc nnprocess">processing function</a> names to
% be used by ith network input. The processing functions are applied to
% input values before the network uses them.
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
% Side Effects:
%
% Whenever this property is altered, the input size is set to 0 and the
% processSettings are set accordingly.
%
% For a list of processing functions, type
%
%   help nnprocess
%
% See also CONFIGURE, TRAIN, SIM

% Copyright 2010 The MathWorks, Inc.
