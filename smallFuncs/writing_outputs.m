function writing_outputs(inputs)   

    results = detecting_objects(inputs.prediction);        
    Area = sum(results.Area);
    PC   = results.PC;
    FN   = inputs.FN;
    LED  = inputs.Light_Bulb;
    FA   = inputs.Foreground_Area;

    TS = split(inputs.TimeStamp,':');
    day    = double(string(TS{1}));
    hour   = double(string(TS{2}));
    minute = double(string(TS{3}));
    second = double(string(TS{4}));

    % saving the output files   
    [path, name, ~] = fileparts(inputs.directory_output);
    % dir_subject = [replace(path,'/','\') , '\' , name];
    dir_subject = [path , '/' , name];

    if exist(dir_subject, 'dir') == 0        
        [status, msg, msgID] = mkdir(path,name);
    end

    dlmwrite( inputs.directory_output ,[FN, PC, Area, FA, LED(1), LED(2), LED(3), day, hour, minute, second]  ,  'delimiter',','  ,  '-append');

    time_stamp = replace(inputs.TimeStamp , ':','_');
    time_stamp = replace(time_stamp , '.','_');

    imwrite(uint16(inputs.frame*(2^16)), [dir_subject, '/frame_'      ,  time_stamp,'.jpg'], 'BitDepth', 16)
    imwrite(inputs.prediction,           [dir_subject, '/prediction_' ,  time_stamp,'.jpg'])
    imwrite(inputs.foreground,           [dir_subject, '/foreground_' ,  time_stamp,'.jpg'])
end