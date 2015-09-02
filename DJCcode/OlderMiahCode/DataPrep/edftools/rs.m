function [y1]=rs(y1,T,f2)
% [y2] = rs(y1, T) resamples y1 to the target sampling rate y2 using T
% [y2] = rs(y1, f1, f2) resamples y1 with f1 to the target sampling rate f2 
%

%	Version 1.10
%	20.07.1999
%	Copyright (c) by  Alois Schloegl
%	a.schloegl@ieee.org	

if nargin==3
        f1=T;
        if f1==f2
                return;
        elseif f1>f2
                D=f1/f2;
                [yr,yc]=size(y1);
                %[size(y1) D, yr yc]
                LEN=yr/D;
                for k=0:LEN-1
                        y1(k+1,:)=sum(y1(k*D+(1:D),:),1)/D;
                end;
                y1=y1(1:LEN,:);
        else %f1<f2
                
        end;
elseif nargin==2
        [f1,f2]=size(T);
        if f1==f2,
                return;
        end;
        [yr,yc]=size(y1);
        LEN=yr/f1;
        for k=0:LEN-1
                y1(k*f2+(1:f2),:)=T'*y1(k*f1+(1:f1),:);
        end;
        y1=y1(1:LEN*f2,:);
end;
%end;
