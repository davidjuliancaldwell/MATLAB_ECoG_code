function [t,s]=compute_tstat(x,y)

n1=numel(x);
n2=numel(y);
s=sqrt(((n1-1)*var(x)+(n2-1)*var(y))/(n1+n2-2));
t=(mean(x)-mean(y))./s/sqrt(1/n1+1/n2);
