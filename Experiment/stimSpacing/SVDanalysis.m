function [u,s,v] = SVDanalysis(data,stimChans)

% transpose data 
data = data';
% data needs to be in m x n form, where m is the number of channels, and n
% is the time points (rows = sensors, columns = samples)

[u,s,v] = svd(data,'econ');

figure
plot(diag(s),'ko','Linewidth',[2])
% to get percentage in mode
subplot(2,1,1) % plot normal
plot(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
title('singular values, fractions')
set(gca,'fontsize',14)

subplot(2,1,2) % plot semilog
semilogy(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
title('singular values, fractions, semilog plot')
set(gca,'fontsize',14)

% look at the modes in space
figure
x = [1:size(data,1)];
plot(x,u(:,1:3),'Linewidth',[2])
title('mode spatial locations'), legend('show')
legend({'mode 1','mode 2','mode 3'});

% color map
CT = cbrewer('div','RdBu',11);

% flip it so red is increase, blue is down
CT = flipud(CT);

%imagesc that 

for i = 1:3
    figure
tempMode = u(:,i);
tempModeGrid = tempMode(1:64);
tempModeStrips = tempMode(65:end);

% get in same order as the CCEP map figure 
imagesc(transpose(reshape(tempModeGrid,[8 8])));
%set(gca,'YDir','reverse')
axis off

colormap(CT);
colorbar;
title(['Grid Electrodes - mode ' num2str(i)]);

% label the grid - from http://stackoverflow.com/questions/3942892/how-do-i-visualize-a-matrix-with-colors-and-values-displayed

textStrings = num2str([1:length(tempModeGrid)]');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:8);   %# Create x and y coordinates for the strings

x = x';
y= y';
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
            
%midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
% textColors = repmat(tempMode(:) > midValue,1,3);  %# Choose white or black for the
%                                              %#   text color of the strings so
%                                              %#   they can be easily seen over
%                                              %#   the background color
% set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

figure
imagesc(tempModeStrips);
colormap(CT);
colorbar;
title(['Strip Electrodes Electrodes - mode ' num2str(i)]);


end

% look at temporal part - columns of v
figure

plot(v(:,1:3),'Linewidth',[2])
title('Temporal portion of the 3 modes'), legend('show')
legend({'mode 1','mode 2','mode 3'});

end