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
           object.solution =randi(Population.MAXIMUM_PIXEL_VALUE, 30,30);
           object.history = 0;
        end
        
        function result = getCurrentValue(object, matrix)
            %The current value displayed by the algorithm.
            %   @object : the current powermeter for which the fake value is sought.
            %   @matrix : a potential solution
            %Locations of Bigger and Smalller.
             biggerThan = matrix > object.solution;
             smallerThan = matrix < object.solution;
            %Power Output
             totalSmall = (smallerThan.*matrix)./(smallerThan.*object.solution + ~smallerThan);
             totalBig = (biggerThan.*object.solution)./(biggerThan.*matrix+~biggerThan);
             currentRating = mean(mean(totalSmall+totalBig));
             
             if (currentRating == 0)
                pause(10000000); 
             end
             object.history = [object.history, currentRating];
             result = currentRating;
        end
    end
end