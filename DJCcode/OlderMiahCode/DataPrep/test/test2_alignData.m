cd c:\users\Jeremiah\research\patients\mara11\data\D3\guger;

for fileNum = 8:11
    
    baseDirs = { 'StimExpt_Baseline\StimExpt_baseline001\';
                 'StimExptPost\StimExpt_Post001\';
                 'StimExptPost\StimExptPost001\';
                 'StimExptPostPost\StimExptPostPost001\';
               };

    baseDirsLookup = [1 1 1 2 3 3 4 4 4 4 4];

    filenames = { 'StimExpt_baselineS001R01.dat';
                  'StimExpt_baselineS001R02.dat';
                  'StimExpt_baselineS001R03.dat';
                  'StimExpt_PostS001R01.dat';
                  'StimExptPostS001R01.dat';
                  'StimExptPostS001R02.dat';
                  'StimExptPostPostS001R01.dat';
                  'StimExptPostPostS001R02.dat';
                  'StimExptPostPostS001R03.dat';
                  'StimExptPostPostS001R04.dat';
                  'StimExptPostPostS001R05.dat';
                };

    baseDir = baseDirs{baseDirsLookup(fileNum)};
    filename = filenames{fileNum};
    file = strcat(baseDir, filename);

    [sig, sta, par] = bci2kQuickLoad(file);

    y = double(sig(:,9));
    
    if (fileNum == 5)
        y = y(1:length(y)-1000);
    elseif (fileNum == 8)
        y = y(1e4:end);
        y = y(1:length(y)-4e4);
    end
%    y = ecogFilter(y, false, 0, true, 5, true, 30, 1200);

    load ..\derived\mara11_channel22.mat;

    for c = 1:5
        start = (c-1) * 5e6 + 1;
        if (c == 5)            
            x = channelData(start:end);
        else
            finish = c * 5e6;
            x = channelData(start:finish);
        end
        
%        x = ecogFilter(x, false, 0, true, 5, true, 30, 2000);

        [d, e] = alignData(x, y, 2000, 1200, 1, true);
    end
end