function geneticAlgorithm(groupsM, groupsN, figureNumber)
    %Matlab genetic algorithm
    
    %Module
    %Constants.
    POWER_IMPROVEMENT = 100000; %Exit when power has improved by this amount time the first one measured.
    POPULATION_SIZE = 100; %The population size.
    CHILDREN_BEFORE_POPULATION_COMBINATION = 20; %The number of children before the populations are combined.
    
    %Variables.
    population = Population(POPULATION_SIZE, groupsM, groupsN, figureNumber); %The population of the genetic algorithm.
    initialPower = getbestValue(population);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    powerProgression = initialPower; %The progression of the power meter's value over time.

    average = 0;
    tmp = 0;
    
    %Module.
    while(getbestValue(population) < initialPower*POWER_IMPROVEMENT)
         %Mutate the individual by combining the values selected in the random
         %templates.
         
         for i =1:CHILDREN_BEFORE_POPULATION_COMBINATION
             ratingOfChild = population.permutate();
             if (average == 0)
                average = sum(population.ratings);
             else
                 tmp = sum(population.ratings);
                 average = [average, tmp];
                 if (tmp < average(length(average)-1))
                     display('???');
                     plot(average);
                     pause(200);
                 end
             end
             figure(2);
             plot(average);
             figure(1);
         end
         
         
    end
    display(['The intial value, ', num2str(initialPower), ', has been augmented successfully by atleast a factor of ', num2str(POWER_IMPROVEMENT), '!']);
end