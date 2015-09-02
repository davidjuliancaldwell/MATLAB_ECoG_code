%we are going to do this number of trials total
TRIAL_COUNT = 100;

%this will hold the record of means and variances we have estimated
means = cell(TRIAL_COUNT,1);
covs = cell(TRIAL_COUNT,1);

%set initial mean and variance
means{1} = 0;
covs{1} = 3;

%first, lets test a stationary case.  The trial's data will be drawn from:
trialMean = 10;
trialCov = 0.05;

%the weight of adjustment we do at each trial will depend on three values:
% a - A fixed learning rate s.t. 0<a<1
% b - A confidence of distribution assignment based on the posterior of the
%   error classifier, which is determined at the end of the trial.
% c - The number of data points making up the trial (to allow us to have
%   variable-length trials at some point).

%think of this as how many data points have already passed.  It gives us
% the product of two things: the learning rate (a above) and a scalar which 
% we multiply by the trial length to get c above. Thus, our update will be
% scaled by b*EFFECTIVE_MEMORY*new_trial_length.
EFFECTIVE_MEMORY = 0.2/100;

%for now, trial length will be fixed
TRIAL_LENGTH = 100;

%Lets suppose that our error classifier gives us uniform [0,1].  This
%implicitly encodes several things: the task, whether the user hit it and
%the user's skill, and error in the classifier itself.  In other words,
%this distribution is a catch-all which just tells us what the output of
%the error coding will look like, without knowing any of these other
%things.  Just simpler this way.


for i = 1:TRIAL_COUNT
   errorFeedback = rand(1);
   
   
   
end

