n1=10;
n2=20;

x=randn(n1,1);
y=randn(n2,1);

np=1000;

tp=zeros(np,1);

x(1)=10;

[h,p,ci,stat]=ttest2(x,y);
t0=stat.tstat;

for i=1:np
    z=[x;y];
    z=z(randperm(n1+n2));
    xp=z(1:n1);
    yp=z(n1+1:end);
    [h,p,ci,stat]=ttest2(xp,yp);
    tp(i)=stat.tstat;
end

