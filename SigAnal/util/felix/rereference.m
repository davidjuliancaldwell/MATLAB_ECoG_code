function out=rereference(in,mode,good_channels)
% function out=rereference(in,mode,good_channels)

out=in;
switch(mode)
    case 'car'
      out=in-repmat(mean(in(:,good_channels),2),1,size(in,2));
    case 'svd'
        car=in-repmat(mean(in(:,good_channels),2),1,size(in,2));
        [U,S,V]=svd(car(:,good_channels),0);
        S(1,1)=0;
        out(:,gc)=U*S*V';
    otherwise
end