function curls = ConvertGloveToCurl(calibRange, gloveGains, f)

%     tic
    minusMin = bsxfun(@minus, f, calibRange(:,1)');
    scaled = bsxfun(@rdivide, minusMin, (calibRange(:,2) - calibRange(:,1))');
    angles = bsxfun(@times, scaled, gloveGains');
    gloveSensors = {[2 3], [5 6 7], [8 9 10], [12 13 14], [16 17 18], [1 2 3 5 6]};
    curls = zeros(size(f,1),5);
    for idx = 1:length(gloveSensors);
        curls(:,idx) = sum(angles(:,gloveSensors{idx}),2);
    end
%     toc
end