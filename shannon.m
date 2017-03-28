area=pi*0.23^2/4;
current=1e-3;
time=1e-3;
charge=current*time;
charge_density=charge/area;
figure;plot(log10(1e6*charge), log10(1e6*charge_density),'ro')
hold on

time=1e-4;
charge=current*time;
charge_density=charge/area;
plot(log10(1e6*charge), log10(1e6*charge_density),'ro')

time=1e-5;
charge=current*time;
charge_density=charge/area;
plot(log10(1e6*charge), log10(1e6*charge_density),'ro')

current=1e-2;
time=1e-3;
charge=current*time;
charge_density=charge/area;
plot(log10(1e6*charge), log10(1e6*charge_density),'ro')

time=1e-4;
charge=current*time;
charge_density=charge/area;
plot(log10(1e6*charge), log10(1e6*charge_density),'ro')

time=1e-5;
charge=current*time;
charge_density=charge/area;
plot(log10(1e6*charge), log10(1e6*charge_density),'ro')

k  = 1.85;
d = [-1:0.1:1.5];
q = k - d;
plot(d,q);
xlabel('log 10 charge/phase')
ylabel('log 10 charge density')