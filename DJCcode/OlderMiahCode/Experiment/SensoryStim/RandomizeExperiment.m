%% set up experiment
freqs = [ 60 70 80]; % frequencies in Hz
thresh = [ 8 8 8]; % perception threshold in mA

ampfactors = [1];

%% calculate psychophysics experimental order

pfreqs = repmat(freqs, length(ampfactors), 1);
pamps =  thresh' * ampfactors;
pamps =  pamps(:)';

order = shuffle(1:(length(ampfactors)*length(freqs)));

spfreqs = pfreqs(order);
spamps  = pamps(order);

for c = 1:length(spfreqs)
    fprintf('stimulus %d: %5.0f Hz at %2.1f mA\n', c, spfreqs(c), spamps(c));
end

fprintf('\n\n\n\n');

%% calculate the combinatorial discrimination experimental order

sz = length(freqs)*length(ampfactors);
reps = 1;

clear pairs;

ctr = 0;
for c = 1:sz
    for d = 1:sz
       
        ctr = ctr + 1;
        pairs{ctr} = [pamps(c) pfreqs(c); pamps(d) pfreqs(d)];
       
    end
end

order = shuffle(repmat(1:length(pairs),1,reps));

spairs = pairs(order);

for c = 1:length(spairs)
    s = spairs{c};
    fprintf('pairing %d:%8.0f Hz at %8.1f mA then %8.0f Hz at %8.1f mA\n', c, ...
        s(1, 2), s(1, 1), s(2, 2), s(2, 1));
end