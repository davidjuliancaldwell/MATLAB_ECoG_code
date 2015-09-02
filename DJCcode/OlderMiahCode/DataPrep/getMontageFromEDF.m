% filename = 'd:\research\subjects\0dd118\clinical\day5.edf';


function [montageTokenized, channelConfig] = getMontageFromEDF(filename)

    if (~exist(filename, 'file'))
        error ('edf file %s does not exist', filename);
    end
    
    edf = sdfopen(filename);
    mStrings = montageCharArrayToStrings(edf.Label);
    [mElts, channelConfig] = getUniqueMontageElements(mStrings);
    
    for c = 1:length(mElts)
        tList = getTrodeListForElement(mElts{c}, mStrings);
        for d = 1:length(tList)
            if (d == 1)
                montageStrung = tList{d};
            else
                montageStrung = [montageStrung ' ' tList{d}];
            end
        end
        
        montageTokenized{c} = [ mElts{c} '(' montageStrung ')' ];
%         [tList, ref] = getTrodeListForElement(mElts{c}, mStrings);
%         
%         for d = 1:length(tList)
%             montageTokenized{resCtr} = [ mElts{c} '(' tList{d} ')' ];
%             resCtr = resCtr + 1;
%         end
    end
end

function mStrings = montageCharArrayToStrings (mCharArray)
    mStrings = cell(size(mCharArray, 1), 1);
    
    for c = 1:length(mStrings)
        mStrings{c} = deblank(mCharArray(c, :));
    end

end

function [uniqueMontageElements, channelRef] = getUniqueMontageElements (mStrings)
    % look through strings for elements of pattern (STR)N.
    % each unique (STR) represents a unique montage element
    
    [~, ~, ~, mtemp] = regexpi(mStrings, '^[a-z]*');    
    matches = decell(mtemp);

    [elts, locs, ref] = unique(matches);
    [~, idxs] = sort(locs);
    
    uniqueMontageElements = elts(idxs);
    
    channelRef = cumsum([1; diff(ref)] ~= 0);
end

function trodeList = getTrodeListForElement (element, mStrings)
    [~, ~, ~, ~, mtemp] = regexp(mStrings, [element '([0-9])+'], 'once');  
    mtemp = stripIfEmpty(mtemp);
    mtemp = decell(mtemp);
    trodeNums = cell2num(mtemp);
    
    trodeDiffs = [1; diff(trodeNums)];
    splits = find(trodeDiffs > 1);
    
    c = 1;
    while (isempty(splits) == false)
        subTrodes = trodeNums(1:(splits(1)-1));
        if (length(subTrodes) > 1)
            trodeList{c} = sprintf('%d:%d', min(subTrodes), max(subTrodes));
        else
            trodeList{c} = num2str(subTrodes(1));
        end
        
        c = c + 1;
        
        trodeNums = trodeNums(splits(1):end);
        trodeDiffs = [1; diff(trodeNums)];
        splits = find(trodeDiffs > 1);
    end
    
    if (isempty(trodeNums))
        trodeList{c} = ':';
    elseif (length(trodeNums) > 1)
        trodeList{c} = sprintf('%d:%d', min(trodeNums), max(trodeNums));
    else
        trodeList{c} = num2str(trodeNums(1));
    end
end

function result = stripIfEmpty (param)
    ctr = 1;
    
    result = {};
    
    for c = 1:length(param)
        if (~isempty(param{c}))
            result{ctr} = param{c};
            ctr = ctr + 1;
        end
    end
end

function result = decell (param)
    result = cell(length(param), 1);
    
    for c = 1:length(param)
        result{c} = param{c}{1};
    end
end

function result = cell2num (param)
    result = zeros(length(param), 1);
    
    for c = 1:length(param)
        result(c) = str2num(param{c});
    end
end