function linkout = removed_data_division
%Some training functions do not support validation
%
%  Training functions that do not support validation will check the
%  network property NET.<a href="matlab:doc nnproperty.net_divideFcn">divideFcn</a> and set it to DIVIDENONE, if it does
%  not have that value already.
%
%    net.<a href="matlab:doc nnproperty.net_divideFcn">divideFcn</a> = 'dividenone'.
%
%  The training function will then use the full data set for training.
%
%  If you wish to train a network with validation and testing,
%  then user a different training function.
%  
%  See also DIVIDENONE

% Copyright 2010 The MathWorks, Inc.

link = nnlink.warning_link('NET.divideFcn has been set to DIVIDENONE.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
