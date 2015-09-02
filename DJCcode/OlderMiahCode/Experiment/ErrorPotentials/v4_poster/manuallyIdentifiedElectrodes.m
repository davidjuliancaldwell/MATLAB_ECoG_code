function [trodes, types] = manuallyIdentifiedElectrodes(subjid)
    switch(subjid)
        case 'fc9643'
            trodes = {'asma([10 12 14 15 16 7 8])',
                      'Grid([11 12 13 14 16 18 2 20 24 26 31 32 36 37 4 40 42 43 44 46 50 51 52 54 56 57 59 7 8 9])',
                      'psma([11 13 14 6 7 8])'};
            types  = {[ 4  4  5  4  4 1 1],
                      [ 1  1  1  1  5  1 1  1  7  1  1  5  1  1 5  1  4  4  4  3  4  4  3  1  5  1  1 1 1 1],
                      [ 1  1  1 5 5 5]};
        case '4568f4'
            trodes = {'Grid([35 37 4 42 47 50 51 57 59])'};
            types = {[ 6  1 2  4  5  4  4  1  4]};
        otherwise
            error('unknown subjid entered: %s', subjid);
    end
end