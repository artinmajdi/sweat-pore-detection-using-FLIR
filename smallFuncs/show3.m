function show3(im1,im2, im3)

ax1 = subplot(131); imshow(im1,[])
ax2 = subplot(132); imshow(im2,[])
ax3 = subplot(133); imshow(im3,[])
linkaxes([ax1,ax2,ax3])

end