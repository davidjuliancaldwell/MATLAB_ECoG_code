Z_Constants;

unsortedDir = fullfile(OUTPUT_DIR, 'unsorted-interaction');
sortedDir = fullfile(OUTPUT_DIR, 'sorted-interaction');

TouchDir(sortedDir);

%%
load(fullfile(META_DIR, 'areas.mat'), 'trodesOfInterest');

files = dir(unsortedDir);

for fileIdx = 1:length(files)
    if(strendswith(files(fileIdx).name, 'png'))
        res = regexpi(files(fileIdx).name, '(\w+)-([0-9]+)-xtrode.png', 'tokens');
        sid = res{1}{1};
        tnum = str2num(res{1}{2});
        sIdx = find(strcmp(SIDS, sid));
        
        load(fullfile(META_DIR, [sid '_results.mat']), 'class', 'cchan');
        
        trs = trodesOfInterest{sIdx};
        trs = trs(trs ~= cchan);

        destDir = fullfile(sortedDir, num2str(class(trs(tnum))));
        TouchDir(destDir);

        from = fullfile(unsortedDir, files(fileIdx).name);
        to = fullfile(destDir, files(fileIdx).name);
        copyfile(from, to);                
    end
end