function y = constrain(x, a, b)
% function y = constrain(x, a, b)
%
% limit x to be greater than or equal to a and less than or equal to b
    y = min(x, b);
    y = max(y, a);
    
end