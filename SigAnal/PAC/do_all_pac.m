subj='S5';
[data,clist,control,fs,tr]=get_subject_data(subj,5,.5,300,4);
data=cheby_filter_notch(data,58,62,fs,4);
data=cheby_filter_notch(data,118,122,fs,4);
data=cheby_filter_notch(data,178,182,fs,4);



for i=1:size(data,2) % do all channels
end
