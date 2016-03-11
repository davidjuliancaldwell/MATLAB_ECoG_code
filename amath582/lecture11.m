%% DJC AMATH 582 - lecture on 2/5/2016 
close all,clear all;clc
x = linspace(0,1,25);
t = linspace(0,2,50); 

% 25 rows is space, 50 columns is time 
[T,X] = meshgrid(t,x);
f = exp(-abs((X-0.5).*(T-1)))+sin(X.*T);

% reduced gives you NOT square matrix, econ only gives you out what you
% want. In GENERAL, use economy method 
[u,s,v] = svd(f,'econ'); 

figure
surfl(X,T,f),% shading interp, colormap(hot) 

% look at diagonal of matrix S - singular values
figure
plot(diag(s),'ko','Linewidth',[2])

% to get percentage in mode
subplot(2,1,1) % plot normal
plot(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
subplot(2,1,2) % plot semilog
semilogy(diag(s)/sum(diag(s)),'ko','Linewidth',[2])

% look at the modes 
figure
plot(x,u(:,1:3),'Linewidth',[2])

% look at temporal part - columns of v
figure
plot(t,v(:,1:3),'Linewidth',[2])

% low rank reconstruction 
figure
subplot(2,2,1), surfl(X,T,f)
for j = 1:3
   ff = u(:,1:j)*s(1:j,1:j)*v(:,1:j)';
   subplot(2,2,j+1)
   surfl(X,T,ff)
    
end

%% next example
close all,clear all;clc
x = linspace(-10,10,100);
t = linspace(0,10,30); 

[X,T] = meshgrid(x,t);
f = sech(X).*(1-0.5*cos(2*T))+(sech(X).*tanh(X)).*(1-0.5*sin(2*T));
[u,s,v] = svd(f','econ'); % he SVD'ed transpose 


figure(1)
surfl(T,X,f),% shading interp, colormap(hot) 

% look at diagonal of matrix S - singular values
figure(2)
plot(diag(s),'ko','Linewidth',[2])

% to get percentage in mode
subplot(2,1,1) % plot normal
plot(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
subplot(2,1,2) % plot semilog
semilogy(diag(s)/sum(diag(s)),'ko','Linewidth',[2])

% look at the modes 
figure(3)
plot(x,u(:,1:3),'Linewidth',[2])

figure(4)
% look at temporal part - columns of v
plot(t,v(:,1:3),'Linewidth',[2])


% low rank reconstruction 
figure(5)
subplot(2,2,1), surfl(X,T,f)
for j = 1:3
   ff = u(:,1:j)*s(1:j,1:j)*v(:,1:j)';
   subplot(2,2,j+1)
   surfl(X,T,ff')
    
end
