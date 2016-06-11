%% scatterplot function 

function [curve1_1st,gof1_1st,curve1_2nd,gof1_2nd] = scatterplot_func(d1)  

% get name of data from input variable 
s = inputname(1);

%scatter with linear fit 
%d1 is subject 1
% (:,3) is 1st ms of pulse, -(:,4) is 2nd, (:,6) is theory 

% plot it 
figure;plot(d1(:,3),d1(:,6),'bo')
hold on;plot(-d1(:,4),d1(:,6),'ro')
xlim([-.6 .6])
ylim([-.6 .6])

% make curve fits 
[curve1_1st,gof1_1st] = fit(d1(:,3),d1(:,6),'poly1','Exclude', isnan(d1(:,3)),'Exclude',isnan(d1(:,6)))
[curve1_2nd,gof1_2nd] = fit(-d1(:,4),d1(:,6),'poly1','Exclude', isnan(d1(:,4)),'Exclude',isnan(d1(:,6)))
a = plot(curve1_1st,'b');
a.LineWidth = 2;
b = plot(curve1_2nd,'r');
b.LineWidth = 2;
x = [-0.6 0.6];
y = [-0.6 0.6];
plot(x,y,'k','linewidth',2)
legend({'1st part of pulse','2nd part of pulse','1st part fit','2nd part fit','line of y = x'},'Location','northwest')
xlabel('Measured voltage (V)')
ylabel('Theoretical Voltage (V)')
title({s,' theory vs. experiment'})

% scatterhist 
figure;
exp =  [d1(:,3);-d1(:,4)];
theory = [d1(:,6);d1(:,6)];
groups = cell(128,1);
groups(1:64) = {'1st'};
groups(65:end) = {'2nd'};
scatterhist(exp,theory,'Group',groups,'PlotGroup','on','Color','br','LineWidth',[2,2],'kernel','on')
xlabel('Measured voltage (V)')
ylabel('Theoretical Voltage (V)')
title({s,' theory vs. experiment'})


end