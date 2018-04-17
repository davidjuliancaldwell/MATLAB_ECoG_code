% setup

T = 5;
fs = 1200;
t = (1:(T*fs))/fs;

An = 1;
Ae = 10;
Al = 5;

fe = 3;
fl = 10;

esec = 1/fe;
lsec = 0.5;

% build the signal
X = An * randn(size(t));

% at 2 seconds in, build the simulated k-complex + spindle
starte = 2*fs;
early = Ae*sin(2*pi*fe*t(t<=esec));
X(starte:(starte+length(early)-1)) = X(starte:(starte+length(early)-1)) + early;

startl = starte+length(early);
late = Al*sin(2*pi*fl*t(t<=lsec));
X(startl:(startl+length(late)-1)) = X(startl:(startl+length(late)-1)) + late;

for order = 2:2:6
    figure
    plot(X, 'linew',2); hold all
    title(sprintf('filter order = %d', order));
    leg = {'original'};

    ctr = 0;
    for hp = 5:2:13
        ctr = ctr + 2;

        % switch which filter is commented to see the change in behavior
        % b/w butterworth and chebychev
        
        [b, a] = cheby1 (order-1, .25, 2 / (fs/2), 'high');
        % [b, a] = butter (order, 2 / (fs/2), 'high');

        fX = filter(b, a, X);
        
        [b, a] = cheby1 (order-1, .25, hp / (fs/2), 'low');
     %    [b, a] = butter (order, hp / (fs/2), 'low');

        fX = filter(b, a, fX);

        plot(fX-ctr*max([Ae An Al]),'linew',2);


        leg{end+1} = sprintf('hp@%dhz', hp);
    end

    legend(leg)
end
    