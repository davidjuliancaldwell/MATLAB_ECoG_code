function ctmr_gauss_plot(cortex,electrodes,weights,side,clims,newFig,colorMapName)
% function [electrodes]=ctmr_gauss_plot(cortex,electrodes,weights,side,clims,newfig)
% projects electrode locations onto their cortical spots in the 
% left hemisphere and plots about them using a gaussian kernel
% for only cortex use: 
% ctmr_gauss_plot(cortex,[0 0 0],0)
% rel_dir=which('loc_plot');
% rel_dir((length(rel_dir)-10):length(rel_dir))=[];
% addpath(rel_dir)
%   Created by:
%   K.J. Miller & D. Hermes, 
%   Dept of Neurology and Neurosurgery, University Medical Center Utrecht
%
%   Version 1.1.0, released 26-11-2009

%load in colormap
if ~exist('colorMapName')
    load('loc_colormap')
else
    load(colorMapName);
end

if ~exist('newFig')
    newFig = 0;
end

if max(ismember(fields(cortex),'vertices')) == 1
    brain=cortex.vertices;
else
    brain=cortex.vert;
end
% v='l';
%view from which side?
temp=1;
if ~exist('side')
    while temp==1
        disp('---------------------------------------')
        disp('to view from right press ''r''')
        disp('to view from left press ''l''');
        v=input('','s');
        if v=='l'      
            temp=0;
        elseif v=='r'      
            temp=0;
        else
            disp('you didn''t press r, or l try again (is caps on?)')
        end
    end
else
    v=side;
end

if length(weights)~=length(electrodes(:,1))
    error('you sent a different number of weights than electrodes (perhaps a whole matrix instead of vector)')
end
%gaussian "cortical" spreading parameter - in mm, so if set at 10, its 1 cm
%- distance between adjacent electrodes
gsp=50;

c=zeros(length(cortex(:,1)),1);
for i=1:length(electrodes(:,1))
    b_z=abs(brain(:,3)-electrodes(i,3));
    b_y=abs(brain(:,2)-electrodes(i,2));
    b_x=abs(brain(:,1)-electrodes(i,1));
%     d=weights(i)*exp((-(b_x.^2+b_z.^2+b_y.^2).^.5)/gsp^.5); %exponential fall off 
    d=weights(i)*exp((-(b_x.^2+b_z.^2+b_y.^2))/gsp); %gaussian 
    c=c+d';
end

% c=(c/max(c));
if max(ismember(fields(cortex),'vertices')) == 1
    if newFig == 1
        figure;
    end
    fv.facevertexcdata = c';
    fv.faces = cortex.faces;
    fv.vertices = cortex.vertices;
    
    patch(fv,'edgecolor','none','facecolor','interp');
    axis tight;
    axis equal;
    hold on
    if version('-release')>=12
       cameratoolbar('setmode', 'orbit')
    else
       rotate3d on
    end
else
    a=tripatch(cortex, newFig, zeros(size(c')));
%     a=tripatch(cortex, newFig, c');
end
shading interp;
a=get(gca);
%%NOTE: MAY WANT TO MAKE AXIS THE SAME MAGNITUDE ACROSS ALL COMPONENTS TO REFLECT
%%RELEVANCE OF CHANNEL FOR COMPARISON's ACROSS CORTICES
d=a.CLim;
if ~exist('clims') || isempty(clims)
    set(gca,'CLim',[-max(abs(d)) max(abs(d))])
else
    set(gca,'CLim',clims);
end
l=light;
colormap(cm)
lighting gouraud; %play with lighting...
% material dull;
material([.3 .8 .1 10 1]);
axis off
set(gcf,'Renderer', 'zbuffer')
% set(gcf,'Renderer','OpenGL') % Tim's edit! For teh speedzor!

if v=='l'
view(270, 0);
set(l,'Position',[-1 0 1])        
elseif v=='r'
view(90, 0);
set(l,'Position',[1 0 1])        
end
% %exportfig
% exportfig(gcf, strcat(cd,'\figout.png'), 'format', 'png', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 600, 'Width', 4, 'Height', 3);
% disp('figure saved as "figout"');