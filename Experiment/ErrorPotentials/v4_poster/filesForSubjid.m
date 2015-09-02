function [files, odir, hemi, bads] = filesForSubjid(subjid)

    switch(subjid)
        case '38e116'
            [odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles('38e116', 2);
            [~,    ~,    ~,    ~, files3] = ErrorPotentialsDataFiles('38e116', 3);
            [~,    ~,    ~,    ~, files5] = ErrorPotentialsDataFiles('38e116', 5);
            [~,    ~,    ~,    ~, files6] = ErrorPotentialsDataFiles('38e116', 6);
            [~,    ~,    ~,    ~, files7] = ErrorPotentialsDataFiles('38e116', 7);
            files = cat(2, files2{1}, files3{1}, files5{1}, files6{1}, files7{1});
        case 'fc9643'
            [odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles('fc9643', 2);
            [~,    ~,    ~,    ~, files3] = ErrorPotentialsDataFiles('fc9643', 3);
            [~,    ~,    ~,    ~, files5] = ErrorPotentialsDataFiles('fc9643', 5);
            files = cat(2, files2{1}, files3{1}, files5{1});
        case '9ad250'
            [odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles(subjid, 2);
            files = files2{1};

        case '4568f4'
            [odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles(subjid, 2);
            files = files2{1};

        case '30052b'
            [odir, hemi, bads, ~, files2] = ErrorPotentialsDataFiles(subjid, 2);
            files = files2{1};
    end
end