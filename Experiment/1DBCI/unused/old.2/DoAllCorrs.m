%%

for c=1:length(Montage.MontageTokenized)
    tok = Montage.MontageTokenized{c};
    idx = strfind(tok, 'Grid');
    if (idx == 1)
        break;
    elseif (c == length(Montage.MontageTokenized))
        Montage
        error('Grid not found in montage, maybe look for grid?');
    end
end

ends = cumsum(Montage.Montage);

if (c == 1)
    start = 1;
else
    start = ends(c-1)+1;
end

interest = start:ends(c);

if (exist('AllPower.m.cache\allcors.mat', 'file'))
    load('AllPower.m.cache\allcors.mat');
else
    upCorrelations = [];
    downCorrelations = [];
    distances = [];
end

controlChannel

upCorrelations = [upCorrelations; upcorrs(interest)];
downCorrelations = [downCorrelations; downcorrs(interest)];
distances = [distances; findGridDistances(controlChannel-(start-1),  1:length(interest))'];

% reshape(findGridDistances(controlChannel-(start-1),  1:length(interest)), 8, 8)

save('AllPower.m.cache\allcors.mat', 'upCorrelations', 'downCorrelations', 'distances');
clear upCorrelations downCorrelations distances
