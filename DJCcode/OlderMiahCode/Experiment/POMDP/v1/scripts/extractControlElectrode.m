function trode = extractControlElectrode(par)
    srcChanIndices = unique(par.Classifier.NumericValue(:, 1));
    if (length(srcChanIndices) > 1)
        error('classifier settings uninterpretable');
    end
    
    trode = par.TransmitChList.NumericValue(srcChanIndices);
end