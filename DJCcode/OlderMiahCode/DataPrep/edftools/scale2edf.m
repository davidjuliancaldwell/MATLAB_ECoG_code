function [EDF,x]=scale2edf(x)

% (c) 31.1.2000
%  Alois Schloegl

EDF.DigMax=(2^15-1)*ones(size(x,2),1);
EDF.DigMin=-2^15   *ones(size(x,2),1);
EDF.PhysMax(:,1)=max(x);
EDF.PhysMin(:,1)=min(x);

for k=1:size(x,2);
    x(:,k)=(x(:,k)-EDF.PhysMin(k))/(EDF.PhysMax(k)-EDF.PhysMin(k))*(2^16-1)-2^15;
end;    
    
    