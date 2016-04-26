%% DJC - 4-13-2016 - Plotting amplitude coefficients for hw #1 

% air - > water
close all;clear all;clc

ni = 1.0;
nt = 1.33;

theta = [0:0.01:90];

thetaT = @(theta) (asind( (ni./nt).*sind(theta)));

r_perp = (ni.*cosd(theta)-nt.*cosd(thetaT(theta)))./(ni.*cosd(theta)+nt.*cosd(thetaT(theta)));
t_perp = (2.*ni.*cosd(theta))./(ni.*cosd(theta)+nt.*cosd(thetaT(theta)));
r_par = (nt.*cosd(theta) - ni.*cosd(thetaT(theta)))./(ni.*cosd(thetaT(theta) + nt.*cosd(theta)));
t_par = (2.*ni.*cosd(theta))./(ni.*cosd(thetaT(theta))+nt.*cosd(theta));

figure
subplot(2,1,1)
plot(theta,real(r_perp),theta,real(t_perp),theta,real(r_par),theta,real(t_par))
legend('r_{\perp}','t_{\perp}','r_{\mid\mid}','t_{\mid\mid}')
title('Amplitude Coefficients vs. incident angle - Air -> Water interface (real components)')
ylabel('Amplitude coefficients')
xlabel('Theta (degrees)')
hold on
hline(0,'k')
ylim([-1 1])



subplot(2,1,2)
plot(theta,imag(r_perp),theta,imag(t_perp),theta,imag(r_par),theta,imag(t_par))
ylabel('Amplitude coefficients')
xlabel('Theta (degrees)')
title('Amplitude Coefficients vs. incident angle - Air -> Water interface (imaginary components)')

legend('r_{\perp}','t_{\perp}','r_{\mid\mid}','t_{\mid\mid}')
ylim([-1 1])

hold on
hline(0,'k')

%% water -> air 
clear all;
ni = 1.33;
nt = 1.0;
theta = [0:0.01:90];

thetaT = @(theta) (asind( (ni./nt).*sind(theta)));


r_perp = (ni.*cosd(theta)-nt.*cosd(thetaT(theta)))./(ni.*cosd(theta)+nt.*cosd(thetaT(theta)));
t_perp = (2.*ni.*cosd(theta))./(ni.*cosd(theta)+nt.*cosd(thetaT(theta)));
r_par = (nt.*cosd(theta) - ni.*cosd(thetaT(theta)))./(ni.*cosd(thetaT(theta) + nt.*cosd(theta)));
t_par = (2.*ni.*cosd(theta))./(ni.*cosd(thetaT(theta))+nt.*cosd(theta));

subplot(2,1,2)

figure
subplot(2,1,1)
plot(theta,real(r_perp),theta,real(t_perp),theta,real(r_par),theta,real(t_par))
legend('r_{\perp}','t_{\perp}','r_{\mid\mid}','t_{\mid\mid}')
title('Amplitude Coefficients vs. incident angle - Water -> Air interface (real components)')
ylabel('Amplitude coefficients')
xlabel('Theta (degrees)')
hold on
hline(0,'k')
ylim([-2 2])



subplot(2,1,2)
plot(theta,imag(r_perp),theta,imag(t_perp),theta,imag(r_par),theta,imag(t_par))
ylabel('Amplitude coefficients')
xlabel('Theta (degrees)')
title('Amplitude Coefficients vs. incident angle - Water -> Air interface (imaginary components)')

legend('r_{\perp}','t_{\perp}','r_{\mid\mid}','t_{\mid\mid}')

hold on
hline(0,'k')
ylim([-2 2])

