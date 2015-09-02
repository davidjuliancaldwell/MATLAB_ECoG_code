% %% collect data
% subjid = 'fc9643';
% subjid = '4568f4';
% subjid = '30052b';
% subjid = '9ad250';
subjid = '38e116';

fprintf('loading original subject data.\n');
[~, odir] = filesForSubjid(subjid);
load(fullfile(odir, [subjid '_epochs']));

%% first check to see if we have already done this
clear markers;  

if (exist(fullfile(odir, [subjid '_epochs_clean.mat']), 'file'))
    load(fullfile(odir, [subjid '_epochs_clean.mat']), 'markers')
    
    if (exist('markers', 'var'))
        resp = input('would you like to use previously determined good and bad trials (Y/n): ', 's');
        
        if (~strcmp(resp, 'n'))
            fresh = false;
        else
            markers = zeros(size(epochs_hg,2),1);
            fresh = true;                    
        end
    else
        markers = zeros(size(epochs_hg,2),1);
        fresh = true;        
    end
else
    markers = zeros(size(epochs_hg,2),1);
    fresh = true;    
end

%% review all epochs

if (fresh)
    fprintf('identifying g/b epochs\n');
    
    fid = figure;

    markers = zeros(size(epochs_hg,2),1);

    e = 1;
    while e <= size(epochs_hg,2)
        clf;
        temp = squeeze(epochs_hg(:,e,:));
        temp(bads,:) = 0;

        
        plot(zscore(temp, 0, 2)');
        title(e);

        waitforbuttonpress;
        key = get(fid,'CurrentCharacter');

        switch(key)
            case 'g'
                markers(e) = 1;
                e = e+1;
            case 'b'
                markers(e) = 0;
                e = e+1;
            case 'u'
                e = max(e-1,1);
            otherwise
                warning('unknown option entered');
        end
    end
end

%% remove bad epochs
epochs_hg = epochs_hg(:,markers==1,:);
epochs_beta = epochs_beta(:,markers==1,:);
epochs_lf = epochs_lf(:,markers==1,:);
if(~isempty(paths))
    paths = paths(:,markers==1,:);
end
ress = ress(markers==1);
tgts = tgts(markers==1);
src_files = src_files(markers==1);

clear fid key e hg beta nhg nbeta resp fresh temp;

fprintf('saving cleaned epochs\n');
save(fullfile(odir, [subjid '_epochs_clean']));
