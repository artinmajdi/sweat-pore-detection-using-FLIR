clc
clear


%% normalize
clc
im1 = read_image(9,true);
im2 = read_image(10,true);

%%
clc
im2 = adaptthresh(imN,'NeighborhoodSize',[3,3], 'ForegroundPolarity','dark', 'Statistic','median');
ax(1) = subplot(121); imshow(imN); title('original')
ax(2) = subplot(122); imshow(im2,[]); title('enhanced')
linkaxes(ax)


%%
clc
function im = read_image(index, normalize)

dir = 'F:\Datasets\FLIR\video sample\tif\';
name = ['Rec-000020 - Copy - test_',int2str(index),'.tif'];
disp(name)
Dirr = [dir, name];
im = imread(Dirr);

if normalize
    mn = min(im(:));
    mx = max(im(:));
    im = uint16(  (im-mn)*(2^16)/(mx-mn)  );
end

end