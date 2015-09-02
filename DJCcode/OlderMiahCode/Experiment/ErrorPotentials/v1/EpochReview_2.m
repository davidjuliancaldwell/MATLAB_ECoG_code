% %% collect data
% subjid = 'fc9643';
% load(fullfile(subjid, [subjid '_epochs']));

%% review all epochs
fid = figure;

markers = zeros(size(epochs,2),1);

e = 1;
while e <= size(epochs,2)
    clf;
    temp = squeeze(epochs(:,e,:));
    temp(bads,:) = 0;
    
    plot(temp');
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

%% remove bad epochs
epochs = epochs(:,markers==1,:);
ress = ress(markers==1);
tgts = tgts(markers==1);

clear fid key e;

save(fullfile(subjid, [subjid '_epochs_clean']));
