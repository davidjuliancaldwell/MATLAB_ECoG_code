% stim electrodes 4 and 60
jp=1;
kp=4;
jm=8;
km=4;
for j=1:8;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v460(j,k)=(1/dp)-(1/dm);
end;
end;
figure;imagesc(v460)

% stim electrodes 12 and 52
jp=2;
kp=4;
jm=7;
km=4;
for j=1:8;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v1252(j,k)=(1/dp)-(1/dm);
end;
end;
figure;imagesc(v1252)


% stim electrodes 20 and 44
jp=3;
kp=4;
jm=6;
km=4;
for j=1:8;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v2044(j,k)=(1/dp)-(1/dm);
end;
end;
figure;imagesc(v2044)


% stim electrodes 28 and 36
jp=4;
kp=4;
jm=5;
km=4;
for j=1:8;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v2836(j,k)=(1/dp)-(1/dm);
end;
end;
figure;imagesc(v2836)