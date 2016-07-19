% calculate the theory and make the heat maps

% calculate the theory for stim electrodes 17 and 24
jp=3;
kp=1;
jm=3;
km=8;
for j=1:6;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v1724(j,k)=(1/dp)-(1/dm);
end;
end;

% calculate the theory for stim electrodes 18 and 23
jp=3;
kp=2;
jm=3;
km=7;
for j=1:6;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v1823(j,k)=(1/dp)-(1/dm);
end;
end;

%calculate the theory for stim electrodes 19 and 22
jp=3;
kp=3;
jm=3;
km=6;
for j=1:6;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v1922(j,k)=(1/dp)-(1/dm);
end;
end;

%calculate the theory for stim electrodes 20 and 21
jp=3;
kp=4;
jm=3;
km=5;
for j=1:6;
for k=1:8;
dxp=j-jp;
dyp=k-kp;
dxm=j-jm;
dym=k-km;
dp=sqrt(dxp^2+dyp^2);
dm=sqrt(dxm^2+dym^2);
v2021(j,k)=(1/dp)-(1/dm);
end;
end;



% make the line plots

for j=1:8;T1724(j)=v1724(1,j);end
for j=1:8;T1724(j+8)=v1724(2,j);end
for j=1:8;T1724(j+16)=v1724(3,j);end
for j=1:8;T1724(j+24)=v1724(4,j);end
for j=1:8;T1724(j+32)=v1724(5,j);end
for j=1:8;T1724(j+40)=v1724(6,j);end
figure;plot(T1724)

for j=1:8;T1823(j)=v1823(1,j);end
for j=1:8;T1823(j+8)=v1823(2,j);end
for j=1:8;T1823(j+16)=v1823(3,j);end
for j=1:8;T1823(j+24)=v1823(4,j);end
for j=1:8;T1823(j+32)=v1823(5,j);end
for j=1:8;T1823(j+40)=v1823(6,j);end
figure;plot(T1823)

for j=1:8;T1922(j)=v1922(1,j);end
for j=1:8;T1922(j+8)=v1922(2,j);end
for j=1:8;T1922(j+16)=v1922(3,j);end
for j=1:8;T1922(j+24)=v1922(4,j);end
for j=1:8;T1922(j+32)=v1922(5,j);end
for j=1:8;T1922(j+40)=v1922(6,j);end
figure;plot(T1922)

for j=1:8;T2021(j)=v2021(1,j);end
for j=1:8;T2021(j+8)=v2021(2,j);end
for j=1:8;T2021(j+16)=v2021(3,j);end
for j=1:8;T2021(j+24)=v2021(4,j);end
for j=1:8;T2021(j+32)=v2021(5,j);end
for j=1:8;T2021(j+40)=v2021(6,j);end
figure;plot(T2021)