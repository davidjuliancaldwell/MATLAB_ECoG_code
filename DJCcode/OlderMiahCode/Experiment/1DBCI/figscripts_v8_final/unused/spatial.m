function [LT, LS] = spatial(f)
% f=imread(x);
% f=im2double(f);
[r,c]=size(f);

LT = zeros(size(f));
LS = zeros(size(f));

for i=1:r
    for j=1:c
        [ip, im, jp, jm] = getIdxs(i, j, r, c);
        
        LT(i,j)=(1/2)*(f(i,j)+ (1/4)*(f(i,jm)+f(i,jp)+f(ip,j)+f(im,j)));
    end
end

return;

HB=2*f-LS; %High boost = A*Original image - Low pass filter
choice=0;
while (choice~=9)
choice=input('1: Low Pass Spatial Filter - Unequal Weights\n2: Low Pass Spatial Filter - Equal Weights\n3: High Pass Spatial Filter - Less Sharper\n4: High Pass Spatial Filter - More Sharper\n5: High-boost Filtering\n6: Median Filtering\n7: Prewitt Derivative Filter\n8: Sobel Derivative Filter\n9: Exit\n Enter your choice : ');
switch choice
    case 1
        imshow(f), title('Original Image'), figure,imshow(LT), title('Low Pass Spatial Filter - Unequal Weights');
    case 2
       imshow(f),title('Original Image'),figure,imshow(LS), title('Low Pass Spatial Filter - Equal Weights');
    case 3
        imshow(f),title('Original Image'),figure,imshow(HT),title('High Pass Spatial Filter - Less Sharper');
    case 4
        imshow(f),title('Original Image'),figure,imshow(HS),title('High Pass Spatial Filter - More Sharper');
    case 5
        imshow(f),title('Original Image'),figure,imshow(HB),title('High Boosting Filter');
    case 6
        imshow(f),title('Original Image'),figure,imshow(MF),title('Median Filter');
    case 7
        imshow(f),title('Original Image'),figure,imshow(DF),title('Prewitt Derivative Filter');
    case 8
        imshow(f),title('Original Image'),figure,imshow(SF),title('Sobel Derivative Filter');
    case 9
        display('Program Exited');
    otherwise
        error('Wrong Choice');
end
end

function [ip, im, jp, jm] = getIdxs(i, j, r, c)
        ip=i+1;
        im=i-1;
        jm=j-1;
        jp=j+1;
        if(im<1)
            im=i;
        elseif (ip>r)
            ip=i;
        end
        if(jm<1)
            jm=j;
        elseif (jp>c)
            jp=j;
        end
end