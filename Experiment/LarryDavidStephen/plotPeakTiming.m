%% script to plot peak timing
close all;clearvars;clc
load('latenciesPeaksData_6_19_2016.mat')

%% smaller matrix
%figure
%gplotmatrix(bigMatrix(:,[1 3 4 7]),[],ccepSID',[],[],[],'on','stairs',bigMatrix_categories([1 3 4 7]));

%% bigger matrix
%figure 
%gplotmatrix(bigMatrix,[],ccepSID',[],[],[],'on','stairs',bigMatrix_categories);

%% individual plots


figure;
h1 = gscatter(betaDist_total,mag_total_ave,ccepSID');
hold on
for i = [1 2 3 4 6 7]
    a = h1(i).XData;
    b = h1(i).YData;
    f = fit(a',b','exp1');
    c = plot(f);
    c.Color = h1(i).Color;
    c.LineWidth = 2;

end
    
xlabel('Distance from Beta recording electrode (mm)')
ylabel('Magnitude of Peak (uV)')
title({'Plot of Peak CCEP Magnitude vs. Distance','from Beta Recording Electrode for All Subjects'})
z = gca;
z.FontSize = 14;
legend({'1','2','3','4','5','6','7'});
y = legend(h1);
y.Title.String = 'Subject';
%% 

figure;

% convert to ms
latency_total_ave = 1000*latency_total_ave;

h2 = gscatter(betaDist_total,latency_total_ave,ccepSID');
hold on
for i = [1 2 3 4 6 7]
    a = h2(i).XData;
    b = h2(i).YData;
    f = fit(a',b','exp1');
    c = plot(f);
    c.Color = h2(i).Color;
    c.LineWidth = 2;
end

xlabel('Distance from Beta recording electrode (mm)')
ylabel('Latency of Peak (ms)')
title({'Plot of CCEP Latency vs. Distance','from Beta Recording Electrode for All Subjects'})
z = gca;
z.FontSize = 14;
legend(h1)
legend({'1','2','3','4','5','6','7'});
y = legend(h2);
y.Title.String = 'Subject';
ylim([0 50])

%%

figure;
h3 = gscatter(betaDist_total,z_total_ave,ccepSID');
hold on
for i = [1 2 3 4 6 7]
    a = h3(i).XData;
    b = h3(i).YData;
    f = fit(a',b','exp1');
    c = plot(f);
    c.Color = h3(i).Color;
    c.LineWidth = 2;
end


xlabel('Distance from Beta recording electrode (mm)')
ylabel('Z scored CCEP magnitude')
title({'Plot of Z Scored CCEP Magnitude vs. Distance','from Beta Recording Electrode for All Subjects'})
z = gca;
z.FontSize = 14;
legend(h1)
legend({'1','2','3','4','5','6','7'});
y = legend(h3);
y.Title.String = 'Subject';

%%

figure;
h6 = gscatter(mag_total_ave,z_total_ave,ccepSID');
hold on
for i = [1 2 3 4 6 7]
    a = h6(i).XData;
    b = h6(i).YData;
    f = fit(a',b','poly1');
    c = plot(f);
    c.Color = h6(i).Color;
    c.LineWidth = 2;
end


xlabel('Magnitude of CCEP Response (uV)')
ylabel('Z scored CCEP magnitude')
title({'Plot of Z scored CCEP Magnitude vs. ','CCEP Amplitude in Microvolts'})
z = gca;
z.FontSize = 14;
legend(h1)
legend({'1','2','3','4','5','6','7'});
y = legend(h6);
y.Title.String = 'Subject';
%%
figure;
h4 = gscatter(latency_total_ave,mag_total_ave,ccepSID');
xlabel('latency total')
ylabel('magnitude of peak')

figure;
h5= gscatter(latency_total_ave,z_total_ave,ccepSID');
xlabel('latency total')
ylabel('z-score magnitude of peak')
