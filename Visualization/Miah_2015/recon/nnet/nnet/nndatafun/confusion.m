function [c,cm,ind,per] = confusion(targets,outputs)
%CONFUSION Classification confusion matrix.
%
%  [C,CM,IND,PER] = <a href="matlab:doc confusion">confusion</a>(T,Y) takes an SxQ target and output matrices
%  T and Y, where each column of T is all zeros with one 1 indicating the
%  target class, and where the columns of Y have values in the range [0,1],
%  the largest Y indicating the models output class.
%
%  It returns the confusion value C, indicating the fraction of samples
%  misclassified, CM an SxS confusion matrix, where CM(i,j) is the number
%  of target samples of the ith class classified by the outputs as class j.
%  
%  IND is an SxS cell array whose elements IND{i,j} contain the sample
%  indices of class i targets classified as class j.
%
%  PER is an Sx4 matrix where each ith row summarizes these percentages
%  associated with the ith class:
%    S(i,1) = false negative rate = false negatives / all output negatives
%    S(i,2) = false positive rate = false positives / all output positives
%    S(i,3) = true positive rate = true positives / all output positives
%    S(i,4) = true negative rate = true negatives / all output negatives
%
%  <a href="matlab:doc confusion">confusion</a>(T,Y) can also take a row vector T of 0/1 target values and a
%  corresponding row vector Y output values.  This case is treated as
%  a two-class case, so CM and IND will be 2x2, and PER 2x3.
%
%  Here a classifier is trained and the confusion values calculated.
%
%    [x,t] = <a href="matlab:doc simpleclass_dataset">simpleclass_dataset</a>;
%    net = patternnet(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x);
%    [c,cm,ind,per] = <a href="matlab:doc confusion">confusion</a>(t,y)
%
% See also PLOTCONFUSION, ROC

% Copyright 2007-2012 The MathWorks, Inc.

if nargin < 2
  error(message('nnet:Args:NotEnough'));
end
if any(size(targets)~=size(outputs))
  error(message('nnet:NNet:TargetOutputMismatch'))
end
if ~all((targets==0) | (targets==1) | isnan(targets))
  warning(message('nnet:confusion:Args'))
  targets = compet(targets);
end

numClasses = size(outputs,1);
if (numClasses == 1)
  targets = [1-targets; targets];
  outputs = [1-outputs-eps*(outputs==0.5); outputs];
  [c,cm,ind,per] = confusion(targets,outputs);
  return;
end

% Unknown/dont-care targets
known = find(isfinite(sum(targets,1)));
targets = targets(:,known);
outputs = outputs(:,known);
numSamples = length(known);

% Transform outputs
outputs = compet(outputs);

% Confusion value
c = sum(sum(targets ~= outputs))/(2*numSamples);
c = full(c);

% Confusion matrix
if nargout < 2, return, end
cm = zeros(numClasses,numClasses);
i = vec2ind(targets);
j = vec2ind(outputs);
for k=1:numSamples
  cm(i(k),j(k)) = cm(i(k),j(k)) + 1;
end

% Indices
if nargout < 3, return, end
ind = cell(numClasses,numClasses);
for k=1:numSamples
  ind{i(k),j(k)} = [ind{i(k),j(k)} k];
end

% Percentages
if nargout < 4, return, end
per = zeros(numClasses,4);
for i=1:numClasses
  yi = outputs(i,:);
  ti = targets(i,:);
  per(i,1) = sum((yi ~= 1)&(ti == 1))/sum(yi ~= 1);
  per(i,2) = sum((yi == 1)&(ti ~= 1))/sum(yi == 1);
  per(i,3) = sum((yi == 1)&(ti == 1))/sum(yi == 1);
  per(i,4) = sum((yi ~= 1)&(ti ~= 1))/sum(yi ~= 1);
end
per(isnan(per)) = 0;

