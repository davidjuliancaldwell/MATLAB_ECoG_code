function [] = SVDplot(u,s,v, fullData, goods, modes)

%% Plot the singular values
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

%% look at the modes in space
% figure
% x = [1:size(data,1)];
% plot(x,u(:,1:3),'Linewidth',[2])
% title('mode spatial locations'), legend('show')
% legend({'mode 1','mode 2','mode 3'});


%% color map
CT = cbrewer('div','RdBu',11);

% flip it so red is increase, blue is down
CT = flipud(CT);

%imagesc that
if fullData
    for i = modes
        figure
        tempMode = u(:,i);
        tempModeFake = zeros(64,1);
        tempModeFake(goods) = tempMode;
        %tempModeGrid = tempMode(1:64);
        %tempModeStrips = tempMode(65:end);
        
        % get in same order as the CCEP map figure
        imagesc(transpose(reshape(tempModeFake,[8 8])));
        %set(gca,'YDir','reverse')
        axis off
        
        colormap(CT);
        colorbar;
        title(['Grid Electrodes - mode ' num2str(i)]);
        
        % label the grid - from http://stackoverflow.com/questions/3942892/how-do-i-visualize-a-matrix-with-colors-and-values-displayed
        
        textStrings = num2str([1:length(tempModeFake)]');  %# Create strings from the matrix values
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
        %
        %         figure
        %         imagesc(tempModeStrips);
        %         colormap(CT);
        %         colorbar;
        %         title(['Strip Electrodes Electrodes - mode ' num2str(i)]);
        
        
    end
end

%% Plot the modes in time (columsn of V)
% look at temporal part - columns of v - indivividually and together
figure
% all together

% get default colormap and use this to plot same as above
subDiag = diag(s);
subDiag = subDiag(1:length(modes));

% scale them by singular values for the combined plot, NOT for individual
numSubs = length(modes)+1;
subplot(numSubs,1,1)
plot(v(:,modes).*repmat(subDiag,[1 size(v,1)])','Linewidth',[2])
title({'Temporal portion of the 3 modes', 'scaled by singular value'}), legend('show')

leg=cell(length(modes),1);
for i=1:length(modes)
    leg{i}=['mode ', num2str(i)];
end
legend(leg);

co = get(gca,'ColorOrder');

for i=1:length(modes)
    subplot(numSubs,1,i+1)
    plot(v(:,modes(i)),'Linewidth',[2],'color',co(i,:));
    title(['Temporal portion of mode #: ', num2str(modes(i))])
end
end