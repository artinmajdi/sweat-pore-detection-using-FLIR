function MAX = detect_light_bulb(rir_filter_input , lightBulb_detection_mode , lightBulb_area)

if lightBulb_detection_mode == "Maximum Birghtness"
    MAX = max(rir_filter_input(:));

elseif lightBulb_detection_mode == "Histogram"
    [a,b] = hist(rir_filter_input(:),4);
    a = a(end-2:end);
    b = b(end-2:end);
    MAX = sum(a.*b)/sum(a);

elseif lightBulb_detection_mode == "Manual ROI" 
    MAX = mean2( rir_filter_input(lightBulb_area) );
    
end

%% temporary - should be deleted
MAX1 = max(rir_filter_input(:));

[a,b] = hist(rir_filter_input(:),4);
a = a(end-2:end);
b = b(end-2:end);
MAX2 = sum(a.*b)/sum(a);

if size(lightBulb_area,1) > 1
    MAX3 = mean2( rir_filter_input(lightBulb_area) );
else
    MAX3 = 0;
end

MAX = [MAX1, MAX2, MAX3];

end