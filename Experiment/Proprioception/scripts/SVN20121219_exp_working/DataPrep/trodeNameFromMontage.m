function trodeName = trodeNameFromMontage(trodeNum, Montage)
    counts = cumsum(Montage.Montage);
    
    if (trodeNum > max(counts))
        error('electrode number exceeding number of channels in montage requested');
    end
    
    idx = find(trodeNum <= counts, 1, 'first');
    
    if (idx == 1)
        trodeInMontageItem = trodeNum;
    else
        trodeInMontageItem = trodeNum - counts(idx-1);
    end
    
    startstr = Montage.MontageTokenized{idx};
    
    [sind, eind, ~, mStr] = regexp(startstr, '\(.*?\)');
    
    mStr = mStr{1}(2:end-1);
    
    if (strcmp(mStr, ':') == 1)
        firstNum = 1;
    else
        [startNumStr, ~] = strtok(mStr, ':');
        firstNum = str2num(startNumStr);
    end

    trodeInMontageItemStr = num2str(trodeInMontageItem + firstNum - 1);    
    trodeName = strrep(startstr, startstr(sind:eind), ['(' trodeInMontageItemStr ')']);
end