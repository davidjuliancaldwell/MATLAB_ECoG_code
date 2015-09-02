% generic setup script for all analyses scripts
tcs;

% subjids = {
%     '26cb98'
%     '04b3d5'
%     '38e116'
%     '4568f4'
%     '30052b'
%     'fc9643'
%     'mg'
%     };

subjids = {'fc9643', '26cb98', '38e116', '4568f4', '30052b', 'mg', '04b3d5'};
ids = {'S1','S2','S3','S4','S5','S6','S7'};

figOutDir = fullfile(myGetenv('output_dir'), '1DBCI', 'figs');
cacheOutDir = fullfile(myGetenv('output_dir'), '1DBCI', 'cache');

up = 1;
down = 2;

big = 30;
small = 22;
