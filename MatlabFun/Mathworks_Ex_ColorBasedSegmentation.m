%% Color based segmentation using k-means clustering example

%% read image
he = imread('hestain.png');
imshow(he), title('H&E image');
text(size(he,2),size(he,1)+15, 'Image courtesty of Alan Partin, Johns Hopkins University', ...
    'FontSize',7,'HorizontalAlignment','right');

%% Convert image from RGB color space to L*a*b color space

cform = makecform('srgb2lab');
lab_he = applycform(he,cform);

%% classify the colors in 'a*b*' Space using k-means clustering

ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

nColors = 3;
% repeat the clustering 3 times to avoid local minima
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
    'Replicates',3);

%% label every pixel in image using results from kmeans

pixel_labels = reshape(cluster_idx,nrows,ncols);
imshow(pixel_labels,[]), title('image labeled by cluster index');

%% create images that segment the H&E image by color
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);

for k = 1:nColors
    color = he;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end

imshow(segmented_images{1}), title('objects in cluster 1');
imshow(segmented_images{2}), title('objects in cluster 2');
imshow(segmented_images{3}), title('objects in cluster 3');

%% segment the nuclei into a separate image

mean_cluster_value = mean(cluster_center,2);
[tmp, idx] = sort(mean_cluster_value);
blue_cluster_num = idx(1);

L = lab_he(:,:,1);
blue_idx = find(pixel_labels == blue_cluster_num);
L_blue = L(blue_idx);
is_light_blue = im2bw(L_blue,graythresh(L_blue));

nuclei_labels = repmat(uint8(0),[nrows ncols]);
nuclei_labels(blue_idx(is_light_blue==false)) == 1;
nuclei_lables = repmat(nuclei_labels,[1 1 3]);
blue_nuclei = he;
blue_nuclei(nuclei_labels ~= 1) = 0;
imshow(blue_nuclei), title('blue nuclei');

