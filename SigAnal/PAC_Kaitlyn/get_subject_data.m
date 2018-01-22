function [data,clist,seed,fs,tt]=get_subject_data(sub,threshold,f1,f2,fo,varargin)
%function [data,clist,control,fs]=get_subject_data(sub,threshold,f1,f2,fo)
% import resting state data and select channels from the seed_members file
% last channel in data is the control electrode
di=dir(fullfile(sub,'*_seed_members*.mat'));
e=0;
seed=[];
fs=[];
tt=[];
data=[];
if ~isempty(di)
    load(fullfile(sub,di(1).name));
    a=whos('*Thresholds');
    if ~isempty(a)
        tt=eval(a.name);
        ixx=find(tt(1,:)>=threshold);
        ix=find(sum(tt(2:end,ixx),2)>0);
        ix(ix==seed)=[];
        e=e+1;
    end
end
if nargin>5
    e=varargin{1};
end
if e>0
    di=dir(fullfile(sub,'*baseline*.dat'));
    if ~isempty(di)
        [signal,states,par]=load_bcidat(fullfile(sub,di(1).name));
        fs=double(par.SamplingRate.NumericValue);
        data=butter_filter(double(signal),f1,f2,fs,fo);
        e=e+1;
    end
end
clist=[];
if e>1 || nargin>5
    clist=ix;
end
