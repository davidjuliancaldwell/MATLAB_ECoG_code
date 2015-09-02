% Neural network output feedbackDelay property.
% 
% NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackDelay">feedbackDelay</a>
%
% This property defines the timestep difference between this output and
% network inputs. Input-to-output network delays can be removed and added
% with <a href="matlab:doc removedelay">removedelay</a> and <a href="matlab:doc adddelay">adddelay</a> functions resulting in this
% property being incremented or decremented respectively.
%
% The difference in timing between inputs and outputs is used by <a href="matlab:doc preparets">preparets</a>
% to properly format simulation and training data and used by <a href="matlab:doc closeloop">closeloop</a>
% to add the correct number of delays when closing an open loop output
% and remove delays when opening a closed loop.
%
% See also REMOVEDELAY, ADDDELEY, OPENLOOP, CLOSELOOP

% Copyright 2010 The MathWorks, Inc.
