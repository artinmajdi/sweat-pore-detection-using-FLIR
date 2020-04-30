function show2(im1,im2)

ax1 = subplot(121); imshow(im1,[])
ax2 = subplot(122); imshow(im2,[])
linkaxes([ax1,ax2])

end