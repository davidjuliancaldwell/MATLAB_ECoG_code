
clearvars -except num ctr;
fig_setup;

% num = 2;

subjid = subjids{num};
id = ids{num};
% clear num;

[files, side, div] = getBCIFilesForSubjid(subjid);

fprintf('running analysis for %s\n', subjid);

alltgts = [];
allress = [];
allsess = [];

ltod = 0;
sessionCounter = 0;

for c = 1:length(files)
    
    fprintf('  processing file %d\n', c);

    file = files{c};
    [~, sta, par] = load_bcidat(file);
    if (num ~= 7)
        tod = datenum(par.StorageTime.Value, 'ddd mmm dd HH:MM:SS yyyy');
    else
        tod = datenum(par.StorageTime.Value, 'yyyy-mm-ddTHH:MM:SS');
    end
    
    if (tod - ltod > 0.333)
        % more than 8 hours has passed since previous recording, mark as a
        % new session
        sessionCounter = sessionCounter + 1;
    end
    
    ltod = tod;
    
    tgts=sta.TargetCode(diff(double(sta.TargetCode)) ~= 0);
    ress=sta.ResultCode(diff(double(sta.ResultCode)) ~= 0);
    tgts(tgts==0) = [];
    ress(ress==0) = [];
    
    alltgts = cat(1, alltgts, tgts);
    allress = cat(1, allress, ress);
    allsess = cat(1, allsess, sessionCounter * ones(size(ress)));
    
end

% %%
% 
% upress = allress(alltgts==1);
% dnress = allress(alltgts==2);
% 
% upress = upress == 1;
% dnress = dnress == 2;
% 
% %%
% 
% figure;
% subplot(211);
% imagesc(upress);
% colormap('gray');
% axis off;
% 
% subplot(212);
% imagesc(dnress);
% colormap('gray');
% axis off;

%%

upsess = allsess(alltgts==1);
dnsess = allsess(alltgts==2);

figure, plot(allsess);
hold on;
plot([div div], [0 max(allsess)], 'k');

% upschg = find([0; diff(upsess)])
% dnschg = find([0; diff(dnsess)])


title(subjid);

