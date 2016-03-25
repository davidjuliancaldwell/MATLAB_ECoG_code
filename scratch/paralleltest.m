% DJC - 3/22/2016 - parallel test suite

function a = MyRand(A)

tic
parfor i = 1:200
    a(i) = max(abs(eig(rand(A))));
end
toc