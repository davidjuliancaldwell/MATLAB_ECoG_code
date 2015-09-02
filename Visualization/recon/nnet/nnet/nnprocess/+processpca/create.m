function [y,settings] = create(x,param)

% Copyright 2012 The MathWorks, Inc.

[~,j] = find(isnan(x));
  j = unique(j);
  x(:,j) = [];
  [R,Q]=size(x);
  settings.name = 'processpca';
  settings.xrows = R;
  settings.maxfrac = param.maxfrac;
  if (R == 0) || (R == 1) || (Q == 0) || (R > Q) || any(any(isinf(x)))
    y = x;
    settings.yrows = R;
    settings.transform = eye(R);
    settings.inverseTransform = eye(R);
    settings.no_change = true;
    return;
  end
  % Use the singular value decomposition to compute the principal components
  [transform,s] = svd(x,0);
  % Compute the variance of each principal component
  var = diag(s).^2/(Q-1);
  % Compute total variance and fractional variance
  total_variance = sum(var,1);
  frac_var = var./total_variance;
  % Find the components which contribute more than min_frac of the total variance
  yrows = sum(frac_var >= param.maxfrac);
  % Reduce the transformation matrix appropriately
  settings.yrows = yrows;
  settings.transform = transform(:,1:yrows)';
  settings.inverseTransform = pinv(settings.transform);
  
  settings.no_change = (settings.xrows == settings.yrows) && ...
    all(all(transform == eye(settings.xrows)));

  y = processpca.apply(x,settings);
  
