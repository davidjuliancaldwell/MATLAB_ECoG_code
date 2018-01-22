function linkout = net_pruned_for_simulink
%Network pruned for Simulink
%
%  Simulink cannot simulate signals with zero elements. Simulink also
%  generates warnings if subsystems contain unused blocks.
%
%  In order to avoid errors and warnings the function <a href="matlab:doc prune">prune</a> is used
%  to delete neural network inputs, layers, outputs and weights which
%  have zero sizes or which do not contribute the networks output.
%
%  Data formatted for the original network can be consistently pruned
%  to work with a pruned network with <a href="matlab:doc prunedata">prunedata</a>.
%  
%  See also GENSIM, PRUNE, PRUNEDATA

% Copyright 2010-2011 The MathWorks, Inc.

link = nnlink.warning_link('Network has been pruned of zero-sized or unused elements.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
