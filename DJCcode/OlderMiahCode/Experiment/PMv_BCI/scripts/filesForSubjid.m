function [files, hemi, bads, montage, cchan] = filesForSubjid(subjid)
    META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'PMv_BCI', 'meta');
    load(fullfile(META_DIR, 'fileInfo.mat'), 'fileInfo', 'subjectList');

    for c = 1:length(subjectList)
        if (strcmp(subjectList{c}, subjid))
            files = fileInfo(c).files;
            hemi  = fileInfo(c).hemi;
            bads  = fileInfo(c).bads;
            montage = fileInfo(c).montage;
            cchan = fileInfo(c).control;
            return;
        end
    end
    
    error('subject %s was not found in subjectList.', subjid);
        
end