subjects = {'854490', '8adc5c', '979eab', '9ab7ab', '9d10c8', 'a3da50', 'a9952e', 'd5cd55'};

for sub = 1:length(subjects);
%     disp(sub);
    
    subjid = subjects{sub}
    
    cd(subjid)
    
    segmentedShuffle_runner(subjid);
    
    cd ..
    
    clearvars -except subjects sub
    
end
