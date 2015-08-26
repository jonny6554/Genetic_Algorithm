classdef PowerMeter<handle
    %This is a fake power meter class.
    properties 
       solution; %The solution that is sought by the algorithm.
       text;
       history; %History of all values
       rating; %The rating of the the solution.
    end
    methods
        function object = PowerMeter(text)
           %Makes a fake powermeter object. 
           %    @text : the fake name of the file.
           %    @object : the fake powerMeter being created
           object.text = text;
           object.solution = randi(30,30);
           object.rating = sum(sum(object.solution));
           object.history = 0;
        end
        
        function result = getCurrentValue(object, matrix)
            %The current value displayed by the algorithm.
            %   @object : the current powermeter for which the fake value is sought.
            %   @matrix : a potential solution
             value = 1/sum(sum(abs(object.solution - matrix)));
             object.history = [object.history, value];
             result = value;
        end
    end
end