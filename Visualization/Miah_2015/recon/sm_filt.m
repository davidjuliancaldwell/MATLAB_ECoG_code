function b=sm_filt(b,sm_par)
%   Created by:
%   D. Hermes & K.J. Miller 
%   Dept of Neurology and Neurosurgery, University Medical Center Utrecht
%
%   Version 1.1.0, released 26-11-2009

sm_par0=sm_par; %for spreading
sm_par=ceil(sm_par); %have to make an integer for lattice

sm_opt='lin';
% sm_opt='gau';


sm_var=((sm_par0+1)/2)^2; %gaussian variance (width = 2*std)

%change smoothing options - gaussian, linear, etc

sm_filt=zeros(2*sm_par+1,2*sm_par+1,2*sm_par+1);

for k=1:(2*sm_par+1), for l=1:(2*sm_par+1), for m=1:(2*sm_par+1), 
if sm_opt=='lin', sm_filt(k,l,m)=((((k-(sm_par+1))^2+(l-(sm_par+1))^2+(m-(sm_par+1))^2)^.5))/(sm_par0+1); end %linear
if sm_opt=='gau', sm_filt(k,l,m)=exp(-((k-(sm_par+1))^2+(l-(sm_par+1))^2+(m-(sm_par+1))^2)/sm_var); end %gaussian
end, end, end
sm_filt=sm_filt.*(sm_filt>0); %b/c linear can go negative

sm_filt=sm_filt/sum(sum(sum(sm_filt)));
            
% filter

b=convn(b,sm_filt);
b(1:sm_par,:,:)=[]; b((size(b,1)-sm_par+1):size(b,1),:,:)=[];
b(:,1:sm_par,:)=[]; b(:,(size(b,2)-sm_par+1):size(b,2),:)=[];
b(:,:,1:sm_par)=[]; b(:,:,(size(b,3)-sm_par+1):size(b,3))=[];




%use divergence of gradient == "no frustrustrated lattices!"  (fix "lattice divits")

%%fix "lattice divits"