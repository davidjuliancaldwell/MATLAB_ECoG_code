function m = nanmode(x)

%only works on vectors


% Find NaNs and set them to zero
nans = isnan(x);
x(nans) = [];

m = mode(x);

end

