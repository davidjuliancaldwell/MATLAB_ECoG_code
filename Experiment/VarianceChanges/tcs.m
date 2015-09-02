% %% set and show off theme colors
theme_colors = ...
    [ ...
        1 1 1;
        0 0 0;
        0.9333 0.9255 0.8824; 
        0.1216    0.2863    0.4902;
        0.3098    0.5059    0.7412;
        0.7529    0.3137    0.3020;
        0.6078    0.7333    0.3490;
        0.5020    0.3922    0.6353;
        0.2941    0.6745    0.7765;
        0.9686    0.5882    0.2745;
    ];

red = 6;
blue = 5;
green = 7;

odir = fullfile(myGetenv('output_dir'), '1DBCI', 'figs');
% figure;
% 
% for c = 1:size(theme_colors,1)
%     t = 1:5;
%     plot(t,t+c,'Color',theme_colors(c,:));
%     hold on;
%     
%     
% end
% 
% legend({'1','2','3','4','5','6','7','8','9','10'});

% round(theme_colors * 255);