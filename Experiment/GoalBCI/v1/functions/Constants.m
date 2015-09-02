% plot some basic things like subject coverage

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

SIDS = {'d6c834', '6cc87c', 'ada1ab', '6b68ef', 'abcdef'};
SUBCODES = {'S1','S2','S3','S4','S5'};

FONT_SIZE = 20;
LEGEND_FONT_SIZE = 14;

UP = [1 2 3 4];
DOWN = [5 6 7 8];
FAR = [1 2 7 8];
NEAR = [3 4 5 6];
BIG = [2 4 6 8];
SMALL = [1 3 5 7];

