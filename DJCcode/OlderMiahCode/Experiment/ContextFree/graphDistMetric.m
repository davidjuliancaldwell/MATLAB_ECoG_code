%suppose we have a Gaussian distribution with:
mean = 0;
var = 4;

%lets graph the gaussDistance between this and various
% other Gaussian distributions given varying vars and means.
means = -5:0.02:10;
vars = 0.1:0.01:7;

%coord grid
[Xs,Ys] = meshgrid(means,vars);

[resX,resY] = size(Xs);

Zs = zeros(size(Xs));

%calculate distance measure at the various tuples of parameters
for i = 1:resX
    for j = 1:resY
        Zs(i,j) = gaussianDistance1d(mean,Xs(i,j),var,Ys(i,j));
    end
end


%graph it
mesh(Xs,Ys,Zs);

