function Montage = sdfmontage(filename)
    EDF = sdfopen(filename, 'r');
    
    Montage = cell(size(EDF.Label, 1), 1);

    for c = 1:length(Montage)
        Montage{c} = strtrim(EDF.Label(c,:));
    end   
    
    sdfclose(EDF);
end