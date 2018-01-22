function [y,settings] = create(x,param)

% Copyright 2012 The MathWorks, Inc.

R = size(x,1);
if  any(param.ind > R)
  error(message('nnet:NNData:XRowIndexTooLarge'));
end

settings.name = 'removerows';
settings.xrows = R;
settings.yrows = R-length(param.ind);
settings.remove_ind = param.ind;
settings.keep_ind = 1:R;
settings.keep_ind(settings.remove_ind) = [];
settings.no_change = isempty(settings.remove_ind);

y = removerows.apply(x,settings);

