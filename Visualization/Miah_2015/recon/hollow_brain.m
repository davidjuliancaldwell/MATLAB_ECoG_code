function [a]=hollow_brain(brain)
%this hollows out the brain prior to tesselation
% D. Hermes & K.J, Miller 240509
% Dept of Neurology and Neurosurgery, University Medical Center Utrecht

%nearest neighbor identification
a=brain(1:(size(brain,1)-2),2:(size(brain,2)-1),2:(size(brain,3)-1)).*...
    brain(2:(size(brain,1)-1),1:(size(brain,2)-2),2:(size(brain,3)-1)).*...
    brain(2:(size(brain,1)-1),2:(size(brain,2)-1),1:(size(brain,3)-2)).*...
    brain(3:(size(brain,1)),2:(size(brain,2)-1),2:(size(brain,3)-1)).*...
    brain(2:(size(brain,1)-1),3:(size(brain,2)),2:(size(brain,3)-1)).*...
    brain(2:(size(brain,1)-1),2:(size(brain,2)-1),3:(size(brain,3)));
%fill edges back in
b=cat(1,zeros(1,size(brain,2)-2,size(brain,3)-2),a,zeros(1,size(brain,2)-2,size(brain,3)-2));
b=cat(2,zeros(size(brain,1),1,size(brain,3)-2),b,zeros(size(brain,1),1,size(brain,3)-2));
b=cat(3,zeros(size(brain,1),size(brain,2),1),b,zeros(size(brain,1),size(brain,2),1));
%remove enclosed points
a=brain-b; a(a<0)=0; clear b g w brain


