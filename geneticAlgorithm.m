function geneticAlgorithm(groupsM, groupsN, figureNumber)
    %Matlab genetic algorithm
    
    %Module
    %Constants.
    POWER_IMPROVEMENT = 10; %Exit when power has improved by this amount time the first one measured.
    POPULATION_SIZE = 100; %The population size.
    %Variables.
    population = Population(POPULATION_SIZE, groupsM, groupsN, figureNumber); %The population of the genetic algorithm.
    initialPower = 0.99;%population.powerMeter.getCurrentValue();%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    powerProgression = initialPower; %The progression of the power meter's value over time.
    mutatedPopulation = population;
    %Changing figure properties.
    colormap(gray(Population.MAXIMUM_PIXEL_VALUE)); %Sets colormap to gray values.
    set(gca, 'CLim', [Population.MINIMUM_PIXEL_VALUE, Population.MAXIMUM_PIXEL_VALUE]); %Makes the colormap limits minimum 0 and the maximum 1. (otherwise -1 and 1)
    axis off; %Turn the axes off on the figure
    %The power meter's output.
    %Module.
    while(bestValue(population) < initialPower*POWER_IMPROVEMENT)
         %Mutate the individual by combining the values selected in the random
         %templates.
         for i =1:20
             ratingOfChild = population.mate();
             powerProgression = [powerProgression, ratingOfChild];
         end
         mutatedPopulation.addToFirst(population);
         population = mutatedPopulation;
    end
end