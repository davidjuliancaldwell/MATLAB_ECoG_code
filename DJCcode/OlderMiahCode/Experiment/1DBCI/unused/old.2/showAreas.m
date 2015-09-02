targetNum = 5;

areas = cell(10, 5);

% jc
areas{ 1, 1} = {'Grid([22, 21, 29, 12, 20], :)'};
areas{ 1, 2} = {};
areas{ 1, 3} = {'Grid([34, 42], :)'};
areas{ 1, 4} = {};
areas{ 1, 5} = {'AntSubfront([2 3 4 5 6 7 8], :)'};
areas{ 1, 6} = {'Grid([13], :)'};

% hh
areas{ 2, 1} = {'Grid([44], :)'};
areas{ 2, 2} = {};
areas{ 2, 3} = {'Grid([16, 24, 40], :)'};
areas{ 2, 4} = {};
areas{ 2, 5} = {'OF([6, 7, 8, 14, 15, 16], :)'};
areas{ 2, 6} = {'Grid([43], :)'};

% 4568f4
areas{ 3, 1} = {'Grid([39, 40, 46, 47, 55, 56], :)'};
areas{ 3, 2} = {};
areas{ 3, 3} = {'Grid([3, 6, 15, 16], :)', 'AP([4, 7, 8, 16], :)', 'PP([3, 7], :)'};
areas{ 3, 4} = {'Grid([16], :)'};
areas{ 3, 5} = {};
areas{ 3, 6} = {'Grid([56], :)'};

% 26cb98
areas{ 4, 1} = {'Grid([28], :)'};
areas{ 4, 2} = {'Grid([60], :)'};
areas{ 4, 3} = {'Grid([63], :)'};
areas{ 4, 4} = {'Grid([32, 40, 39, 30], :)'};
areas{ 4, 5} = {};
areas{ 4, 6} = {'Grid([36], :)'};

% 30052b
areas{ 5, 1} = {};
areas{ 5, 2} = {};
areas{ 5, 3} = {};
areas{ 5, 4} = {};
areas{ 5, 5} = {};
areas{ 5, 6} = {'Grid([29], :)'};

% mg
areas{ 6, 1} = {'Grid([5], :)'};
areas{ 6, 2} = {};
areas{ 6, 3} = {'Grid([23, 24], :)'};
areas{ 6, 4} = {'Grid([31], :)'};
areas{ 6, 5} = {};
areas{ 6, 6} = {'Grid([12], :)'};

% jt2
areas{ 7, 1} = {'Grid([48, 56, 64], :)'};
areas{ 7, 2} = {};
areas{ 7, 3} = {};
areas{ 7, 4} = {};
areas{ 7, 5} = {};
areas{ 7, 6} = {'Grid([64], :)'};

% 04b3d5
areas{ 8, 1} = {'Grid([37, 46], :)'};
areas{ 8, 2} = {};
areas{ 8, 3} = {'Grid([33], :)'};
areas{ 8, 4} = {};
areas{ 8, 5} = {};
areas{ 8, 6} = {'Grid([45], :)'};

% fc9643
areas{ 9, 1} = {'Grid([15, 16], :)'};
areas{ 9, 2} = {'Grid([55, 56], :)'};
areas{ 9, 3} = {};
areas{ 9, 4} = {};
areas{ 9, 5} = {};
areas{ 9, 6} = {'Grid([24], :)'};

% 38e116
areas{10, 1} = {'Grid([25, 26], :)'};
areas{10, 2} = {};
areas{10, 3} = {};
areas{10, 4} = {};
areas{10, 5} = {};
areas{10, 6} = {'Grid([33], :)'};

targets = {'jc', ...
        'hh', ...
        '4568f4', ...
        '26cb98', ...
        '30052b', ...
        'mg', ...
        'jt2', ...
        '04b3d5', ...
        'fc9643', ...
        '38e116'};

hemis = ['l', 'r', 'r', 'r', 'r', 'l', 'r', 'l', 'r', 'r'];

colors = [
    [1 0 0];
    [0 1 0];
    [0 0 1];
    [.3 .6 .9];
    [1 1 0];
    [1 0.5 0];
    [0 0.5 1];
    [1 0 0.5];
    [1 0.5 0.5];
    [0.5 1 0.5];
    [0.5 0.5 1];
];
outDir = [myGetenv('output_dir') '\remoteAreas'];

target = targets{targetNum};

e_tgt = ['e_' target];
PlotCortex(e_tgt);
PlotElectrodes(e_tgt, {'AllTrodes'}, [.8 .8 .8], true, false, false);

for area = 1:size(areas, 2)
    for trodeSet = areas{targetNum, area}
        PlotElectrodes(e_tgt, trodeSet, colors(area, :), false, false, true);
    end
end

if (strcmp(target, 'jc') == 1 || ...
    strcmp(target, 'mg') == 1 || ...
    strcmp(target, '04b3d5') == 1 )
    view(270,0);
else
    view(90,0);
end

maximize;
SaveFig(outDir, ['areas_' target]);
['areas_' target]