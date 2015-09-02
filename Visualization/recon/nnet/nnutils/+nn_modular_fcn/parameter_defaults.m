function defaults = parameter_defaults(f)

% Copyright 2012 The MathWorks, Inc.

parameterInfo = feval([f '.parameterInfo']);
defaults = struct;
for i=1:length(parameterInfo)
  field = parameterInfo(i).fieldname;
  default = parameterInfo(i).default;
  defaults.(field) = default;
end
