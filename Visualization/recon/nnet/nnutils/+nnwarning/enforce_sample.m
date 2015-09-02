function linkout = enforce_sample
%Some training functions can only divide data according to samples.
%
%  Training functions that require a sample data division to operate
%  correctly, will set NET.<a href="matlab:doc nnproperty.net_divideMode">divideMode</a> to SAMPLE , if its original
%  value was not 'none' or 'sample'.
%
%    net.<a href="matlab:doc nnproperty.net_divideMode">divideMode</a> = 'sample'.
%
%  The training function is then able to divide data properly.
%
%  If you wish to train a network with a different data division mode,
%  you should use a different training function.
%  
%  See also TRAINB, TRAINC, TRAINS

% Copyright 2010 The MathWorks, Inc.

link = nnlink.warning_link('NET.divideMode was set to SAMPLE.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
