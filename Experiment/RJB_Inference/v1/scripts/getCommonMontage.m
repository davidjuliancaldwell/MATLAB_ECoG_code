function Montage = getCommonMontage(fileList)
    if (isempty(fileList))
        error('fileList cannot be empty');
    end
    
    for idx = 1:length(fileList)
        mMontage = loadCorrespondingMontage(fileList{idx});
        
        if (idx == 1)
            Montage = mMontage;
        else
            if (strcmp(Montage.MontageString, mMontage.MontageString) == 1)
                Montage.BadChannels = union(Montage.BadChannels, mMontage.BadChannels);
            else
                warning('montage %idx does not match 1st montage, skipping\n');
            end
        end
    end
end