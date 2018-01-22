function out = GaussianSmooth(input, kernWidth)
% gaussKern = gausswin(kernWidth);
% out = conv(gaussKern, input); 
% out([1:(floor(length(gaussKern)/2)-1) floor(length(out)-length(gaussKern)/2+1):end]) = [];

% if size(input,2) > size(input,1)
%     input = input';
% end
input = [repmat(input(1,:),kernWidth,1);input;repmat(input(end,:),kernWidth,1)];
pc1s=conv2(gausswin(kernWidth)/sum(gausswin(kernWidth)),1,input,'same');

pc1s(1:kernWidth,:) = [];
pc1s(end-kernWidth+1:end,:) = [];

out = pc1s;
