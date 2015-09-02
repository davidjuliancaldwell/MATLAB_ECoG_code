

function y=convert2normal(x)
% function y=convert2normal(x)
% converts the input values to normally distributed values
 
[a,ix]=sort(x);
 nn=(0:length(x)-1)/length(x);
 p=x;
 p(ix)=nn;
 y=norminv(p);
 %y(isinf(y))=0;
 y(isinf(y)) = min(y(~isinf(y)));
 y = y/(max(max(y), abs(min(y))));
end
 