function [new_data]=butter_filter(d,low_freq,high_freq,SR,fo)
% function [new_data]=butter_filter(d,low_freq,high_freq,SR,fo)
W_low=2*low_freq/SR;
W_high=2*high_freq/SR;
% % Butterwertfilter bauen;
% [Ah,Bh]=butter(fo,[W_low],'high');
% %disp(sprintf('filter length=%i\n',length(Ah)))
% new_data=filtfilt(Ah,Bh,d);
% [Ah,Bh]=butter(fo,[W_high],'low');
% new_data=filtfilt(Ah,Bh,new_data);
% % for i=1:size(d,2)
% %    new_data(:,i)=filtfilt(Ah,Bh,d(:,i));
% % end
if(W_low>0 && W_high>0)
 [b,a]=butter(fo,[W_low W_high]);
end
if(W_low>0 && W_high<0)
     [b,a]=butter(fo,[W_low],'high');
end
if(W_low<0 && W_high>0)
     [b,a]=butter(fo,[W_high],'low');
end
new_data=filtfilt(b,a,d);