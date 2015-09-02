% common across all remote areas analysis scripts
subjids = {
    '26cb98'
    '04b3d5'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };

allfiles = {};

for c = 1:length(subjids)
    subjid = subjids{c};    
    [files, ~, ~] = getBCIFilesForSubjid(subjid);
    allfiles = cat(2,allfiles, files);
end
    
fid = figure;

for d = 11:13%1:length(allfiles)
    fname = allfiles{d};
    
    fprintf('%d: working on %s\n', d, fname);
    mname = strrep(fname, '.dat', '_montage.mat');

    if (exist(mname, 'file'))
        load(mname);
    else
        error('no montage file found: %s', mname);
    end

    [sig, sta, par] = load_bcidat(fname);
    bads = [];

    e = 1;
    while e <= max(cumsum(Montage.Montage))
%     for e = 1:max(cumsum(Montage.Montage))
         wasbad = ismember(e,Montage.BadChannels);

         plot(sig(:,e));

         if (wasbad)
             col = 'r';
         else
             col = 'k';
         end

         title(trodeNameFromMontage(e, Montage), 'Color', col);

         km = waitforbuttonpress;
         key = get(fid,'CurrentCharacter');
         
         if strcmp(key, 'b')
             bads = [bads e]
             e = e+1;
         elseif strcmp(key, 'u')
             bads(bads==(e-1)) = []
             e = max(1, e-1);
         else
             e = e+1;
         end
    end

    Montage.BadChannelsOld = Montage.BadChannels;
    Montage.BadChannels = bads;

%     save(mname, 'Montage');
end
