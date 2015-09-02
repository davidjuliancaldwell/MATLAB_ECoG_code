function list = getElectrodeList(subjid)
    switch(subjid)
        case '9ad250'
            list = [20 97 98]; % 9ad250
        case 'fc9643'
            list = [7 8 12 16 20 32 54 88]; % fc
        case '4568f4'
            list = [2 14 33 37 47 57 58 62 66 85 95 96]; % 4568f4
        case '30052b'
            list = [7 18 19 27 28 50 69 79 ]; % 30052b
        otherwise
            list = [];
    end
end
