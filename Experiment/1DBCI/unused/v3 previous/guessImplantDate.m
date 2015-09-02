subjids = {
    '26cb98'
    '04b3d5'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };


for c = 1:length(subjids)
    subjid = subjids{c};
    
    files = getBCIFilesForSubjid(subjid);
    
    [~, ~, par] = load_bcidat(files{1});
    extractSubjid(files{1})
    par.StorageTime.Value{:}
%     try 
%         d = datevec(par.StorageTime.Value{:}, 'ddd mmm dd HH:MM:SS YYYY');
%     catch
%         d = datevec(par.StorageTime.Value{:}, 'YYYY-MM-DDTHH:mm:ss');
%     end
%     
%     datestr(d, 'ddd mmm/dd')
    
    
    
end