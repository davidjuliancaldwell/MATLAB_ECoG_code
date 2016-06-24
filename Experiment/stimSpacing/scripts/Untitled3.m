test = sin(0:0.1:2*pi);

t = 0:0.1:16*pi;
x = sin(t) + 10*randn(1,length(t));
y = 5*sin(t) + 10*randn(1,length(t));
figure
plot(t,[x; y]);
figure
plot([conv(x,test); conv(y,test)]');