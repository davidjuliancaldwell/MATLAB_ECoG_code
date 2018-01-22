% subject is encoded subject ID
% Montage is a montage from a given recording (or set of recordings)
function bas = basFromMontage(subject, Montage)    
    base = getSubjDir(subject);
    
    load(fullfile(base, 'other', 'brod_areas.mat'));
    if(isrow(areas))
        areas = areas';
    end
    
    bas = [];
    
    load(fullfile(base, 'trodes.mat'));
    
    starts = zeros(size(TrodeNames));
    ends   = zeros(size(TrodeNames));
    
    prev = 0;
    for c = 1:length(TrodeNames)
        trodeName = TrodeNames{c};
        
        starts(c) = prev+1;
        eval(sprintf('ends(c) = prev + size(%s, 1);', trodeName));
        prev = ends(c);
    end
    
    for token = Montage.MontageTokenized
        [name, idxStr] = processToken(token{:});  
        
        if (isempty(idxStr) || strcmp(idxStr, ':'));
            idxStr = eval(sprintf('[''1:'' num2str(size(%s, 1))]', name));
        end
        
        if (~strcmp(name, 'empty'))
            elementIndex = find(strcmp(name, TrodeNames));
            eval(sprintf('mbas = areas(starts(elementIndex)-1+(%s));',idxStr));
            bas = [bas; mbas];
        end
    end
end

function [name, idxStr] = processToken(token)
    inpar = strfind(token, '(');
    outpar = strfind(token, ')');
    
    name = token(1:(inpar-1));
    idxStr = token((inpar+1):(outpar-1));
end