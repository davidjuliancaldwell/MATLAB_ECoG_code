function y = map(x, x_min, x_max, y_min, y_max)
% remaps y from the scale x_min:x_max to y_min:ymix
% ex map(1:3, 0, 4, 4, 0) returns 3:-1:1
    x_range = x_max-x_min;
    y_range = y_max-y_min;
    
    scale_fac = y_range/x_range;
    y = (x - x_min)*scale_fac+y_min;
    
%     offset = y_min-x_min
%     
%     offset_m = ones(size(x))*offset;
%    
%     y = (x+offset_m)*scale_fac;
end