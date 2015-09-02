function [y,err]=random_phase_pdf(x,l)
% function [y,err]=random_phase_pdf(x,l)
% computes the pdf for the phaselocking value x after averaging over l
% trials
r=x*l;
if(length(x)>1)
    y=zeros(size(x));
    err=y;
    for i=1:length(x)
        [q,erri]=quadgk(@(x)i_func(x,r(i),l),0,inf,'RelTol',1e-8,'AbsTol',1e-12,'MaxIntervalCount',1500);
        y(i)=l*r(i)*q;
        err(i)=erri;
    end
else
    [q,err]=quadgk(@(x)i_func(x,r,l),0,inf,'RelTol',1e-8,'AbsTol',1e-12,'MaxIntervalCount',1500);
    y=l*r*q;
end

function x=i_func(u,r,l)
x=u.*besselj(0,r*u).*((besselj(0,u)).^l);