%point 1
mu1 = 2;
sig1 = 1;

%point 2
mu2 = -7;
sig2 = 4;


path = zeros(100,3);

for i = 1:100
   [mu,sig] = gaussInterpolate(mu1,sig1,mu2,sig2,i/100);
   path(i,1:2) = [mu,sig];
   path(i,3) = gaussianDistance1d(mu1,mu,sig1,sig);
end


scatter(path(:,1),path(:,2))


% 
% figure;
% plot(path(:,3));  %should be a line
% figure;
% scatter(path(:,1),path(:,2));   %some sort of path
% 
% 
% diff1 = path(2:100,3) - path(1:99,3);
% mean(diff1)  %could be anything positive
% var(diff1)  %should be damn close to 0