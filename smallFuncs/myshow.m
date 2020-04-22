function myshow(separate_joined,mode,varargin)
    for x = 1:length(varargin)
        
        if strcmp(separate_joined,'joined')
            if strcmp(mode,'imshow')
                ax(x) = subplot(1,length(varargin),x); imshow(varargin{x});
            elseif strcmp(mode,'imtool')
                ax(x) = subplot(1,length(varargin),x); imtool(varargin{x},[]);
            end
        else                       
            if strcmp(mode,'imshow')
                ax(x) = figure;
                imshow(varargin{x},[]);
            elseif strcmp(mode,'imtool')
                ax(x) = imtool(varargin{x},[]);
            end                  
        end
    end
    linkaxes(ax)
end