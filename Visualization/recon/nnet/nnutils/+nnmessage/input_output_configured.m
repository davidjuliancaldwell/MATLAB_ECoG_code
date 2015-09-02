function linkout = input_output_configured
%Training functions automatically configure network inputs and outputs.
%
%  Blah blah
%  
%  See also CONFIGURE, TRAIN

% Copyright 2010 The MathWorks, Inc.

link = nnlink.message_link('Network inputs and outputs have been configured.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
