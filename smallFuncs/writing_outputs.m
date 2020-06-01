function writing_outputs(inputs)

    results = detecting_objects(inputs.prediction);        
    Area = sum(results.Area);
    PC   = results.PC;
    FN   = inputs.FN;
    LED  = inputs.Light_Bulb;
    FA  = inputs.Foreground_Area;
    
    TS = split(inputs.TimeStamp,':');
    day    = double(string(TS{1}));
    hour   = double(string(TS{2}));
    minute = double(string(TS{3}));
    second = double(string(TS{4}));
    
    dlmwrite( inputs.Directory_output ,[FN, PC, Area, FA, LED(1), LED(2), LED(3), day, hour, minute, second]  ,  'delimiter',','  ,  '-append');

end