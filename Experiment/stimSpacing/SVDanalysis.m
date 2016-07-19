function [u,s,v] = SVDanalysis(data,stimChans,fullData,ignore,goodChans)

if(~exist('fullData','var'))
    fullData = true;
end

if(exist('ignore','var'))
    % ignore badChans for SVD
    goods = ones(size(data,2),1);
    goods(ignore) = 0;
    goods = logical(goods);
    
    %fullData(:,~goods) = 0;
    dataTrim = data(:,goods);
end

if(exist('goodChans','var'))
    goods = zeros(size(data,2),1);
    goods(goodChans) = 1;
    goods = logical(goods);
    dataTrim = data(:,goods);
end


% transpose data
dataSVD = dataTrim';
% data needs to be in m x n form, where m is the number of channels, and n
% is the time points (rows = sensors, columns = samples)

[u,s,v] = svd(dataSVD,'econ');

% have to augment u.

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
% figure
% x = [1:size(data,1)];
% plot(x,u(:,1:3),'Linewidth',[2])
% title('mode spatial locations'), legend('show')
% legend({'mode 1','mode 2','mode 3'});

% color map
CT = cbrewer('div','RdBu',11);

% flip it so red is increase, blue is down
CT = flipud(CT);

%imagesc that
if fullData
    for i = 1:3
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

% look at temporal part - columns of v - indivividually and together
figure
% all together

% get default colormap and use this to plot same as above
subDiag = diag(s);
subDiag = subDiag(1:3);

% scale them by singular values for the combined plot, NOT for individual
subplot(4,1,1)
plot(v(:,1:3).*repmat(subDiag,[1 size(v,1)])','Linewidth',[2])
title({'Temporal portion of the 3 modes', 'scaled by singular value'}), legend('show')
legend({'mode 1','mode 2','mode 3'});

co = get(gca,'ColorOrder');

subplot(4,1,2)
plot(v(:,1),'Linewidth',[2],'color',co(1,:));
title('Temporal portion of 1st mode')


subplot(4,1,3)
plot(v(:,2),'Linewidth',[2],'color',co(2,:))
title('Temporal portion of 2nd mode')


subplot(4,1,4)
plot(v(:,3),'Linewidth',[2],'color',co(3,:))
title('Temporal portion of 3rd mode')


end