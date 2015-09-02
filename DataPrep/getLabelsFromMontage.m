function labels = getLabelsFromMontage(Montage, trodes)
    labels = cell(length(trodes),1);
%     sumMon = cumsum(Montage.Montage);
    count = 0;
    
    for c = trodes
        count = count + 1;
        labels{count} = trodeNameFromMontage(c, Montage);
        
%         idx = find(c <= sumMon, 1);
%         if (idx > 1)
%             modifier = sumMon(idx-1);
%         else
%             modifier = 0;
%         end
%         
%         [start, endd] = regexp(Montage.MontageTokenized{idx}, '\([0-9]*:[0-9]*\)');
%         
%         labels{count} = strrep(Montage.MontageTokenized{idx}, Montage.MontageTokenized{idx}(start+1:endd-1), num2str(c-modifier)); 
%         count = count + 1;
    end    
end