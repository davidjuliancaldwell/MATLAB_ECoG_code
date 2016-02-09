%% From larry, 1/18/2016, 1/r continuum model
% relevant to 3x3 stim

% the 1/r theory for 3x3 data set

% stim electrodes 20 and 22
jp=3;
kp=4;
jm=3;
km=6;
for j=1:8;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v1(j,k)=(1/dp)-(1/dm);
end;
end;

% stim electrodes 28 and 30
jp=4;
kp=4;
jm=4;
km=6;
for j=1:8;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v2(j,k)=(1/dp)-(1/dm);
end;
end;

% stim electrodes 36 and 38
jp=5;
kp=4;
jm=5;
km=6;
for j=1:8;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v3(j,k)=(1/dp)-(1/dm);
end;
end;

% use superposition
V=v1+v2+v3;

% scale theory to experiment (20 mV)
% DJC notes - this was arbitrary to make the scales agree. If Brain,
% electrode impedences right, this would fall out 
thy=100*V/7.242;