function plotlr(lr,t)
%PLOTLR Plot network learning rate vs epochs.
%  
% Obsoleted in R2008b NNET 6.0.  Last used in R2007b NNET 5.1.
%

nnerr.obs_fcn('barerr','Use BAR to make bar plots.')

%  PLOTLR(LR,T)
%    LR - row vector of network learning rates.
%         The first value is associated with
%         epoch 0, the second with epoch 1, etc.
%    T  - (Optional) String for graph title.
%         Default is 'Network Learning Rate'.

% Mark Beale, 1-31-92
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.11.4.3 $  $Date: 2011/02/28 01:30:42 $

if nargin > 2 | nargin < 1
  error(message('nnet:Args:NotEnough'));
end

plot(0:length(lr)-1,lr);
xlabel('Epoch')
ylabel('Learning Rate')

if nargin == 1
  title('Network Learning Rate')
else
  title(t)
end
