N = 10000;
trialsPerRun = 17;

hr = zeros(N,1);

for c = 1:N
    hr(c) = randbinom(.5,trialsPerRun)/trialsPerRun;
end

shr = sort(hr);
lidx = ceil((0.05/2)*N);
hidx = floor((1-(0.05/2))*N);

fprintf('Chance Performance = %1.4f [%1.4f, %1.4f]\n', mean(hr), shr(lidx), shr(hidx));