function writing_outputs(inputs)

    results = detecting_objects(inputs.prediction);        
    Area = mean(results.Area);
    PC   = results.PC;
    FN   = inputs.FN;
    MAX  = inputs.MAX;
    dlmwrite( inputs.Directory_output ,[FN, Area,PC,MAX],'delimiter',',','precision',5,'-append');

end