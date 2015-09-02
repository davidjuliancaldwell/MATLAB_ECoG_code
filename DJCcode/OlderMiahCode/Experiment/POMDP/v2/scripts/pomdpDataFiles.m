function [hemi, bads, files] = errorPotentialsDataFiles(subjid)
    Z_Constants;
    
    load(fullfile(META_DIR, 'fileInfo.mat'), 'fileInfo', 'subjectList');
    
    % find subjid in the subjectList
    found = false;
    
    for idx = 1:length(subjectList)
        if (strcmp(subjectList{idx}, subjid))
            found = true;
            break;
        end
    end
    
    if (~found)
        error('subject id %s was not found in the meta file, maybe rerun B_BuildFileMetaData.m');
    end
    
    hemi = fileInfo.hemi;
    bads = fileInfo.bads;
    files = fileInfo.files;
    
end
