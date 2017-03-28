%% DJC 1-13-2017 - demonstration of how to shift and unshift a vector

% example a la Jenny - starts a shift, more or less a cyclic shift of the
% data
a = [1:10]
shift = 4
b = a([shift:end 1:shift-1])
c = zeros(size(b))
c([shift:end 1:shift-1]) = b

% example a la Mathworks - randomly change each number
