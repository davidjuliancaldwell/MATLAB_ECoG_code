

figure;plot(d1(:,3),d1(:,6))
figure;plot(d1(:,3),d1(:,4))
figure;plot(d1(:,3),-d1(:,4))
close all
close all


figure;plot(d1(:,3),-d1(:,4))
figure;plot(d2(:,3),-d2(:,4))
figure;plot(d3(:,3),-d3(:,4))
figure;plot(d4(:,3),-d4(:,4))
figure;plot(d5(:,3),-d5(:,4))
figure;plot(d6(:,3),-d6(:,4))
figure;plot(d7(:,3),-d7(:,4))
close all
close all
figure;plot(d1(:,3),d1(:,6))
figure;plot(d2(:,3),d2(:,6))
figure;plot(d3(:,3),d3(:,6))
figure;plot(d4(:,3),d4(:,6))
figure;plot(d5(:,3),d5(:,6))
figure;plot(d6(:,3),d6(:,6))
figure;plot(d7(:,3),d7(:,6))
close all


figure;plot(d1(:,3),d1(:,6),'bo')
figure;plot(d2(:,3),d2(:,6),'bo')
figure;plot(d3(:,3),d3(:,6),'bo')
figure;plot(d4(:,3),d4(:,6),'bo')
figure;plot(d5(:,3),d5(:,6),'bo')
figure;plot(d6(:,3),d6(:,6),'bo')
figure;plot(d7(:,3),d7(:,6),'bo')
close all
close all

% looks like blue dots are 1st msec, red are 2nd
% (:,4) is the 2nd measured msec (inverted to account for the switch it
% polarity
% (:,3) is the 1st measured msec)
% (:,6) is the theory 
figure;plot(d1(:,3),d1(:,6),'bo')
hold on;plot(-d1(:,4),d1(:,6),'ro')
figure;plot(d2(:,3),d2(:,6),'bo')
hold on;plot(-d2(:,4),d2(:,6),'ro')
figure;plot(d3(:,3),d3(:,6),'bo')
hold on;plot(-d3(:,4),d3(:,6),'ro')
figure;plot(d4(:,3),d4(:,6),'bo')
hold on;plot(-d4(:,4),d4(:,6),'ro')
figure;plot(d5(:,3),d5(:,6),'bo')
hold on;plot(-d5(:,4),d5(:,6),'ro')
figure;plot(d6(:,3),d6(:,6),'bo')
hold on;plot(-d6(:,4),d6(:,6),'ro')
figure;plot(d7(:,3),d7(:,6),'bo')
hold on;plot(-d7(:,4),d7(:,6),'ro')