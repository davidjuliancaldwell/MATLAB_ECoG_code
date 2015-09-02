function [signal] = skyline(steps,mn_width,mx_width,mn_height,mx_height)
%
%  <a href="matlab:doc skyline">skyline</a>](length,mn_width,mx_width,mn_height,mx_height) takes:
%	    length    - Length of sequence to be created
%	    mn_width  - Minimum step width
%	    mx_width  - Maximum step width
%	    mn_height - Minimum step height
%	    mx_height - Maximum step height
%	  and returns 
%	    signal  - Sequence of random heights and widths
%
%  For example, here random skyline data is generated, plotted, and
%  converted to neural network time series format.
%
%    x = <a href="matlab:doc skyline">skyline</a>(100,3,19,0.1,10);
%    plot(x)
%    x = <a href="matlab:doc con2seq">con2seq</a>(x)
%
%  See also CON2SEQ, SEQ2CON.

% Copyright 2010 The MathWorks, Inc.

rangeW = mx_width - mn_width;
rangeH = mx_height - mn_height;

total = 0;
i = 0;
while total < steps,
    i = i + 1;
    w(i) = fix(rand*rangeW + mn_width);
    total = total + w(i);
    h(i) = rand*rangeH + mn_height;
end

w(i) = w(i) - (total - steps);
num_w = i;

start = 0;
signal = zeros(1,steps);
for i=1:num_w,
    signal(start+(1:w(i))) = h(i);
    start = start + w(i);
end

