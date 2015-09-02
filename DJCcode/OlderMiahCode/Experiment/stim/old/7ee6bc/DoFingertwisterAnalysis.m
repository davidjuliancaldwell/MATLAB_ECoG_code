% do finger twister analysis

subjid = '7ee6bc';

load(sprintf('%s_ft_ds.mat', subjid));

rs = FTScreen(ds, true);

save(sprintf('%s_ft_rs.mat', subjid));

SaveFig(pwd, sprintf('%s_ft', subjid));