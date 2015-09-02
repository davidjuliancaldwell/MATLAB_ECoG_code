% make 7ee6bc stim fingertwister dataset

ds.subjId = '7ee6bc';
ds.surf.dir = [myGetenv('subject_dir') '\' ds.subjId];
ds.surf.file  = 'cortex.mat';

ds.trodes.dir = [myGetenv('subject_dir') '\' ds.subjId];
ds.trodes.file  = 'trodes.mat';

ds.stimTrodes = [47 55];

i = 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId '\data\D1\guger\finger_twister_guger001'];
ds.recs(i).file  = 'pre_finger_twister.dat';
ds.recs(i).type = 'bci2k';
ds.recs(i).trigger = 'stimulus';
ds.recs(i).name = 'session 1';
ds.recs(i).rest = 1;
ds.recs(i).activity = 2:7;

i = i + 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId '\data\D3\derived'];
ds.recs(i).file  = 'fingerTwisterClinDataD3.mat';
ds.recs(i).type = 'clinical';
ds.recs(i).trigger = 'stimulus';
ds.recs(i).name = 'session 2';
ds.recs(i).rest = 1;
ds.recs(i).activity = 2:7;

save('7ee6bc_ft_ds', 'ds');

clear i;