% selected = find([results{:,2}] == 300 & [results{:,3}] == 200 );
% times = vec2mat([results{selected,5}],5);
% 
% figure;
% 
% plot([results{selected,1}],times,'marker','s');
% title('Time in seconds for vector length of 50000 & window size of 300');