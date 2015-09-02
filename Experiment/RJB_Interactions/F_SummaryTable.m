%%
Z_Constants;

warning ('currently excluding 38e116');
SCODES(strcmp(SIDS, '38e116')) = [];
SIDS(strcmp(SIDS, '38e116')) = [];

%%

fprintf('SID|\tCOVG|\tEPI|\tA|\tU|\tD|\tt|\te|\tc|\t0|\tp|\n');
fprintf('------------------------------------------------------\n');

for zid = SIDS
    sid = zid{:};    
    load(fullfile(META_DIR, [sid '_epochs']), 'tgts', 'ress', 'bad_marker', 'bad_channels');
    load(fullfile(META_DIR, [sid '_results']), 'class');
   
    good_trials = ~all(bad_marker);
    
    fprintf('%s\t%s\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%1.2f\n', ...
        sid, 'covg', 'note', sum(good_trials), sum(tgts(good_trials)==1), sum(tgts(good_trials)~=1), ...
        sum(~isnan(class)), sum(class==2), sum(class==1), sum(class==0), mean(tgts(good_trials)==ress(good_trials)));
end
