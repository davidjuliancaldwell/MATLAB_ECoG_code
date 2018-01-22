function flag = has_boiler(mfunction)
%HAS_BOILER Returns true if function has boilerplate code.

% Copyright 2010 The MathWorks, Inc.

boiler = nn_getboiler(mfunction);
flag = ~isempty(boiler);
