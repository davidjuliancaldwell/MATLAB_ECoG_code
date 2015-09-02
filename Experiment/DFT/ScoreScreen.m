skipcount = 0;
scores = [];
difficulties = [];

for c = 1:length(newlist)
    [~,sta,par] = load_bcidat(newlist{c});
    
%     if(par.TaskDifficulty.NumericValue ~= 5)
%         skipcount = skipcount + 1;
%         [~,a,~] = fileparts(newlist{c});
%         fprintf('skipping %d: %s\n', a);
%     
%     else
        scores(end+1) = sta.GameScore(end);
        difficulties(end+1) = par.TaskDifficulty.NumericValue;
%     end
end

%%
colors = 'rgbkcy';
figure;

for difficulty = unique(difficulties)
    plot(find(difficulties == difficulty), scores(difficulties == difficulty), [colors(difficulty==unique(difficulties)) '*']);
    hold on;
end

legend('1','2','3','4','5');


