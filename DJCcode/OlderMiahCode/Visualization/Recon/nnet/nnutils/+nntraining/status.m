function status = status(name,units,scale,form,min,max,value)

% Copyright 2007-2010 The MathWorks, Inc.

status.name = name;
status.units = units;
status.scale = scale; % linear, log
status.form = form; % discrete, continuous
status.min = min;
status.max = max;
status.value = value;
