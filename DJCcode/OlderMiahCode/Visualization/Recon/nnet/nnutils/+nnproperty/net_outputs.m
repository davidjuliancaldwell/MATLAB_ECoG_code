% Neural network outputs property.
% 
% NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>
%
% This property holds structures of properties for each of the network's
% outputs. It is always a 1 x Nl cell array, where Nl is the number of
% network outputs (net.<a href="matlab:doc nnproperty.net_numOutputs">numOutputs</a>).
%
% The structure defining the properties of the output from the ith layer
% (or a null matrix []) is located at net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i} if
% net.<a href="matlab:doc nnproperty.net_outputConnect">outputConnect</a>(i) is 1 (or 0).
%
% Each output has the following properties:
%
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_name">name</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackInput">feedbackInput</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackDelay">feedbackDelay</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackMode">feedbackMode</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processFcns">processFcns</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processParams">processParams</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processSettings">processSettings</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processedRange">processedRange</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_processedSize">processedSize</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.outputRange">range</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_size">size</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_userdata">userdata</a>

% Copyright 2010-2012 The MathWorks, Inc.
