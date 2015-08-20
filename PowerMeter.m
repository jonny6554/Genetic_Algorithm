classdef PowerMeter<handle
    %This is a fake power meter class.
    properties 
       solution; %The solution that is sought by the algorithm.
       text;
       history; %History of all values
    end
    methods
        function object = PowerMeter(text)
           %Makes a fake powermeter object. 
           %    @text : the fake name of the file.
           %    @object : the fake powerMeter being created
           object.text = text;
           size = get(gcf, 'Position');
           object.solution = randi(300,300);
           object.history = 0;
        end
        
        function result = getCurrentValue(object, matrix)
            %The current value displayed by the algorithm.
            %   @object : the current powermeter for which the fake value is sought.
            %   @matrix : a potential solution
             
             value = 1/sum(sum(abs(object.solution - matrix)));
             object.history = [object.history, value];
             figure(2);
             plot(object.history);
             figure(1);
             result = value;
        end
    end
end