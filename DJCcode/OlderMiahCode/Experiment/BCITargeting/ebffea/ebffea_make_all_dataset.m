% make octb09 all bci dataset

clear ds;

ds.subjId = 'ebffea';
ds.type = 'all';
ds.surf.dir = [myGetenv('subject_dir') '\' ds.subjId '\surf'];
ds.surf.file  = 'ebffea_cortex.mat';

ds.trodes.dir = [myGetenv('subject_dir') '\' ds.subjId];
ds.trodes.file  = 'trodes.mat';

ds.electrodes = 1:64;

% overt
% d2/1,2,3
% d3/1,2
% d4/1

% im
% d2/3
% d3/2,3,4,5
% d4/1

i = 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId '\D7\ebffea_2targ_fast_2s001'];
ds.recs(i).file  = 'ebffea_2targ_fast_2sS001R02.dat';
ds.recs(i).montage = 'ebffea_2targ_fast_2sS001R02_montage.mat';
ds.recs(i).type = 'bci2k';
ds.recs(i).movement = 'imagined';
ds.recs(i).trodes = ds.electrodes;

i = i + 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId '\D7\ebffea_2targ_fast_2s001'];
ds.recs(i).file  = 'ebffea_2targ_fast_2sS001R03.dat';
ds.recs(i).montage = 'ebffea_2targ_fast_2sS001R03_montage.mat';
ds.recs(i).type = 'bci2k';
ds.recs(i).movement = 'imagined';
ds.recs(i).trodes = ds.electrodes;

i = i + 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId '\D7\ebffea_2targ_fast_2s001'];
ds.recs(i).file  = 'ebffea_2targ_fast_2sS001R04.dat';
ds.recs(i).montage = 'ebffea_2targ_fast_2sS001R04_montage.mat';
ds.recs(i).type = 'bci2k';
ds.recs(i).movement = 'imagined';
ds.recs(i).trodes = ds.electrodes;

i = i + 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId '\D7\ebffea_2targ_fast_2s001'];
ds.recs(i).file  = 'ebffea_2targ_fast_2sS001R05.dat';
ds.recs(i).montage = 'ebffea_2targ_fast_2sS001R05_montage.mat';
ds.recs(i).type = 'bci2k';
ds.recs(i).movement = 'imagined';
ds.recs(i).trodes = ds.electrodes;

i = i + 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId '\D7\ebffea_2targ_fast_2s001'];
ds.recs(i).file  = 'ebffea_2targ_fast_2sS001R06.dat';
ds.recs(i).montage = 'ebffea_2targ_fast_2sS001R06_montage.mat';
ds.recs(i).type = 'bci2k';
ds.recs(i).movement = 'imagined';
ds.recs(i).trodes = ds.electrodes;

i = i + 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId '\D7\ebffea_2targ_fast_2s001'];
ds.recs(i).file  = 'ebffea_2targ_fast_2sS001R07.dat';
ds.recs(i).montage = 'ebffea_2targ_fast_2sS001R07_montage.mat';
ds.recs(i).type = 'bci2k';
ds.recs(i).movement = 'imagined';
ds.recs(i).trodes = ds.electrodes;

save('ebffea_all_ds', 'ds');

clear i;