function y = apply(x,settings)
%REMOVECONSTANTROWS.APPLY

% Copyright 2012 The MathWorks, Inc.

if settings.no_change
  y = x;
  return;
end

if isempty(settings.remove_ind)
  y = x;
else
  y = x(settings.keep_ind,:);
end
