% temp
load('d:\research\subjects\d74850\other\bcifiles.mat');
% /temp

scores = [];
difficulties = [];
indScores = [];
codes = [];
days = [];

for c = 1:length(newlist)
    fprintf('processing %d\n',c);
    
    [~,sta,par] = load_bcidat(newlist{c});
    
    [scores(end+1),foo,temp] = deriveISE(sta, par);
    difficulties(end+1) = par.TaskDifficulty.NumericValue;
    
    [starts, ~] = getEpochs(sta.Feedback, 1, false);
    
    indScores = cat(1, indScores, temp);
    codes = cat(1, codes, double(sta.TargetCode(starts)));
    
    temp2 = regexp(newlist{c}, '\\d([0-9])[s\\]', 'tokens');
    day = str2num(temp2{1}{1});     
    
    dayst = ones(size(temp)) * day;
    
    days = cat(1, days, dayst);
    
    
end

%%

code = 1;

figure;
% plot(GaussianSmooth(indScores(codes==code), 3));
plot(indScores(codes==code), '*');
hold on;

[~, locs] = unique(days(codes==code));
locs = [1; locs(1:(end-1))+1];

for c = 1:length(locs);
    plot([locs(c) locs(c)], ylim, 'k', 'LineWidth', 2);
end

xlabel('trial');
ylabel('performance metric');

if (code == 2)
    title('multi day bci performance, down targets');
elseif (code == 1)
    title('multi day bci performance, up targets');
end

% %%
% colors = 'rgbkcy';
% figure;
% 
% for difficulty = unique(difficulties)
%     plot(find(difficulties == difficulty), scores(difficulties == difficulty), [colors(difficulty==unique(difficulties)) '*']);
%     hold on;
% end
% 
% legend('1','2','3','4','5');
% 
% 
% %%
% 
% for c = 1:length(newlist)
%     temp = regexp(newlist{c}, '\\d([0-9])[s\\]', 'tokens');
%     day(c) = str2num(temp{1}{1}); 
% end
% 
% for c = 1:length(u)
%     vertline = find(day==u(c), 1, 'first');
%     plot([vertline vertline], ylim, 'k', 'LineWidth', 2);
% end
% 
