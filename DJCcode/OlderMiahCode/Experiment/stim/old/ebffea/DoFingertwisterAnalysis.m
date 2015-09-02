% do finger twister analysis

subjid = 'ebffea';

load(sprintf('%s_ft_ds.mat', subjid));

% TODO fix path
temp = pwd;
cd ..;
rs = FTScreen(ds, true);
cd(temp);

save(sprintf('%s_ft_rs.mat', subjid));

SaveFig(pwd, sprintf('%s_ft', subjid));