%% DJC 1-18-2016, this requires the 3x3 stim data to be loaded 

% Plot the 1/r theory on top of the 8x8 data
x=[1,150000];
figure;for j=1:64;subplot(8,8,j);plot(1000*Wave.data(:,j));hold on;end
for j=1:8;
y=[thy(1,j),thy(1,j)];
hold on;subplot(8,8,j);plot(x,y,'r')
hold on;subplot(8,8,j);plot(x,-y,'r')
end;
for j=1:8;
y=[thy(2,j),thy(2,j)];
hold on;subplot(8,8,j+8);plot(x,y,'r')
hold on;subplot(8,8,j+8);plot(x,-y,'r')
end;
for j=1:8;
y=[thy(3,j),thy(3,j)];
hold on;subplot(8,8,j+16);plot(x,y,'r')
hold on;subplot(8,8,j+16);plot(x,-y,'r')
end;
for j=1:8;
y=[thy(4,j),thy(4,j)];
hold on;subplot(8,8,j+24);plot(x,y,'r')
hold on;subplot(8,8,j+24);plot(x,-y,'r')
end;
for j=1:8;
y=[thy(5,j),thy(5,j)];
hold on;subplot(8,8,j+32);plot(x,y,'r')
hold on;subplot(8,8,j+32);plot(x,-y,'r')
end;
for j=1:8;
y=[thy(6,j),thy(6,j)];
hold on;subplot(8,8,j+40);plot(x,y,'r')
hold on;subplot(8,8,j+40);plot(x,-y,'r')
end;
for j=1:8;
y=[thy(7,j),thy(7,j)];
hold on;subplot(8,8,j+48);plot(x,y,'r')
hold on;subplot(8,8,j+48);plot(x,-y,'r')
end;
for j=1:8;
y=[thy(8,j),thy(8,j)];
hold on;subplot(8,8,j+56);plot(x,y,'r')
hold on;subplot(8,8,j+56);plot(x,-y,'r')
end;
