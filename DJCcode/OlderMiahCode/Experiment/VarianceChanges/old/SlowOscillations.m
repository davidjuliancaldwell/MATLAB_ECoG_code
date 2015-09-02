% Script for teasing out slow oscillations

% first, run the first block from FirstPass to get files cell array

c = 0;

for mfile = files{1}
    c = c + 1;
    
    if (c > 5) 
        return
    end
   
    load(strrep(mfile{:}, '.dat', '_work.mat'));
    
    
end
    


