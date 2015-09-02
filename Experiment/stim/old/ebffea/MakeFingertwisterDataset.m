% make 7ee6bc stim fingertwister dataset

ds.subjId = 'ebffea';
ds.surf.dir = [myGetenv('subject_dir') '\' ds.subjId '\surf'];
ds.surf.file  = 'cortex.mat';

ds.trodes.dir = [myGetenv('subject_dir') '\' ds.subjId];
ds.trodes.file  = 'trodes.mat';

ds.stimTrodes = [46 38];

i = 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId];
ds.recs(i).file  = 'finger_twisterS001R03.dat';
ds.recs(i).type = 'bci2k';
ds.recs(i).trigger = 'glove';
ds.recs(i).name = sprintf('session %d', i);
ds.recs(i).rest = 1;
ds.recs(i).activity = 2:3;

i = i + 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId];
ds.recs(i).file  = 'finger_twisterS001R04.dat';
ds.recs(i).type = 'bci2k';
ds.recs(i).trigger = 'glove';
ds.recs(i).name = sprintf('session %d', i);
ds.recs(i).rest = 1;
ds.recs(i).activity = 2:3;

i = i + 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId];
ds.recs(i).file  = 'finger_twisterS001R05.dat';
ds.recs(i).type = 'bci2k';
ds.recs(i).trigger = 'glove';
ds.recs(i).name = sprintf('session %d', i);
ds.recs(i).rest = 1;
ds.recs(i).activity = 2:3;

i = i + 1;
ds.recs(i).dir = [myGetenv('subject_dir') '\' ds.subjId];
ds.recs(i).file  = 'finger_twisterS001R06.dat';
ds.recs(i).type = 'bci2k';
ds.recs(i).trigger = 'glove';
ds.recs(i).name = sprintf('session %d', i);
ds.recs(i).rest = 1;
ds.recs(i).activity = 2:3;


save('ebffea_ft_ds', 'ds');

clear i;