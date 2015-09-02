% Neural network inputs property.
% 
% NET.<a href="matlab:doc nnproperty.net_inputs">inputs</a>
%
% This property holds structures of properties for each of the network's
% inputs. It is always an Ni x 1 cell array of input structures, where Ni
% is the number of network inputs (net.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>).
%
% The structure defining the properties of the ith network input is
% located at
%
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}
%
% Each input has the following properties:
%
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_name">name</a>
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_feedbackOutput">feedbackOutput</a>
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_processFcns">processFcns</a>
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_processParams">processParams</a>
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_processSettings">processSettings</a>
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_processedRange">processedRange</a>
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_processedSize">processedSize</a>
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_range">range</a>
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_size">size</a>
%   net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_userdata">userdata</a>

% Copyright 2010 The MathWorks, Inc.
