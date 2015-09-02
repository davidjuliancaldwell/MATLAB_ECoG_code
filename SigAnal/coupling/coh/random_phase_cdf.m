function [y,err]=random_phase_cdf(x,l)
% function y=random_phase_cdf(x,l)
if(length(x)==1)
[y,err]=quadgk(@(r)random_phase_pdf(r,l),0,x,'RelTol',1e-8,'AbsTol',1e-12);
else
    y=zeros(size(x));
    err=y;
    for i=1:length(x)
        if mod(i,100)==0
            fprintf('sample %d\n',i);
        end
        [yi,erri]=quadgk(@(r)random_phase_pdf(r,l),0,x(i),'RelTol',1e-8,'AbsTol',1e-12);
        y(i)=yi;
        err(i)=erri;
    end
end