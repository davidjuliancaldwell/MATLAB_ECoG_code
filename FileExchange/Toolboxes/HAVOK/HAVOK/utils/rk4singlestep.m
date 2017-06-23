function yout = rk4singlestep(fun,dt,t0,y0)

f1 = fun(t0,y0);
f2 = fun(t0+dt/2,y0+(dt/2)*f1);
f3 = fun(t0+dt/2,y0+(dt/2)*f2);
f4 = fun(t0+dt,y0+dt*f3);

yout = y0 + (dt/6)*(f1+2*f2+2*f3+f4);