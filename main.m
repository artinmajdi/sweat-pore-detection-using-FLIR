clc
clear
addpath(genpath('.'))

mode = menu('Select the experiment mode', 'one tif frame', 'tif video', 'ats video');
if mode == 1 
    frame_index = inputdlg('enter the frame number');
    frame_index = str2double(frame_index{1});
end
    
[name,path] = uigetfile('H:\Datasets\FLIR Datasets\sample\Rec-000020\','Select Input Video');
input_mode = strsplit(name,'.');
input_mode = input_mode{2};

%%

if mode == 1       
    if strcmp(input_mode, 'tif'); im = imread([path,name], frame_index); end
    [prediction, im_enhanced] = segmentation(im);
else   
    [Area , PC] = save_video_from_video_tif(path, name);
end