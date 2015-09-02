function p=bootstrp3(x,n)

p=zeros(size(x,1),size(x,2),n);
for i=1:n
    ix=randi(size(x,3),size(x,3),1);
    p(:,:,i)=mean(x(:,:,ix),3);
end
