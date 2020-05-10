
background = imclose(frame < 0.4 ,strel('disk',20));
background(300:end,:) = 0;

[img,threshOut] = edge(frame,'Sobel',[],'Both');
img = imclose(img, strel('disk',10));
img = im2single(img,'indexed');


ax(1) = subplot(121); imshow(im_enhanced);
ax(2) = subplot(122); imshow(prediction);
% ax(3) = subplot(133); imshow(prediction2);
linkaxes(ax)