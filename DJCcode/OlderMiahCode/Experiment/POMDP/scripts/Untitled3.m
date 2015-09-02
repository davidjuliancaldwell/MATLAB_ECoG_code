% grab and reshape the hg GRID data

foo = squeeze(sr2(5,1:64,:));

foo2 = zeros(8,8,70);

for x = 1:8
    for y = 1:8
        foo2(x,y,:) = foo((y-1)*8+x, :);
    end
end

maxs = [];
% shuffle and calculate largest blob
for n = 1:100
    sfoo = reshape(shuffle(foo2(:)), [8, 8, 70]);
    val = bwlabeln(sfoo);
    ar = regionprops(val, 'FilledArea');
    maxs(n) = max([ar(:).FilledArea]);
end

% find the 95% on blob size
minblob = prctile(maxs, 95);

% now do it on the real data
val = bwlabeln(foo2);
ar = regionprops(val, 'FilledArea');
sizes = [ar(:).FilledArea];
goods = find(sizes>=minblob);

%%
h = ismember(val, goods);

rfoo = foo2 .* h;