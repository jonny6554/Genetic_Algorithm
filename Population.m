classdef Population < handle
   %This represents a population of individuals. A population contains
   %individuals and ratings of those individuals. Note that an individual
   %class was not made to increase the speed of the program. See the link 
   %bellow for analysis.
   %[Reference: http://blogs.mathworks.com/loren/2012/03/26/considering-performance-in-object-oriented-matlab-code/]
   properties (Access = private)
       ratings_; %The value which ranks the quality of the individual in the population (in this case the powermeter's output.)
       individuals_; %A matrix representing the individual.
       index; %Indicates the location of the highest to lowest values in the array.
       powerMeter_; %The value pointing towards the power meter object.
       m; %Number of lines in one individual.
       n; %Number of columns in one invidual.
       window; %The figure onto which members of the population are displayed on the SLM.
   end
   properties (Dependent)
      powerMeter; %This value contains an address pointing towards powerMeter.
      ratings; %This value contains an adress pointing towards rating_.
      individuals; %This value contains an address pointing towards individual_.
   end
   properties (Constant)
       MAXIMUM_PIXEL_VALUE = 255; %The maximum value a pixel can be.
       MINIMUM_PIXEL_VALUE = 0; %The minimum value a pixel can be.
       NAME_OF_POWERMETER_OUTPUT_FILE = 'test.txt'; %The name of the file that the power meter ourputs to.
   end
   methods
       function object = Population(size, m, n, figureNumber)
           %Constructs an object that represents the current population.
           %    @size : The size of the population. (e.g. 100 is 100 population)
           %    @m : the number of lines in the division of the figure
           %    @n : the number of columns in the division of the figure.
           %    @figureNumber : the number of the figure on which the
           %    population's individuals are displayed.
           %    @object : the population being created.
            
           %Module
           object.m = m;
           object.n = n;
           object.window = figure(figureNumber);
           object.ratings_(size) = 0;
           object.powerMeter_ = PowerMeter(Population.NAME_OF_POWERMETER_OUTPUT_FILE);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           %Set the figure
           set(object.window,'menubar','none','units','pixels');
           set(object.window,'Resize','off'); % Disable resizing 
           set(object.window,'BackingStore','off'); %Disable backstoring to print faster.
           colormap(gray(Population.MAXIMUM_PIXEL_VALUE)); %Sets colormap to `gray values.
           set(gca, 'CLim', [Population.MINIMUM_PIXEL_VALUE, Population.MAXIMUM_PIXEL_VALUE]); %Makes the colormap limits minimum 0 and the maximum 1. (otherwise -1 and 1)
           axis off;
           windowSize = get(object.window, 'position'); %Gets window position and size.
           set(gca,'units','pixels','position',[0 0 windowSize(3) windowSize(4)]); %Bottom left corner is 0,0
           
           %Setting up the object again.
           object.individuals_(:, :, :) = randi([Population.MINIMUM_PIXEL_VALUE, Population.MAXIMUM_PIXEL_VALUE], [m, n, size]);
           for i = 1:size
              object.ratings_(i) = rate(object, object.individuals_(:,:,i));
           end
           [object.ratings_, object.index] = sort(object.ratings_, 'descend');
       end
       
       function result = rate(object, individual)
            %Rates an individual of the population.
            %   individual : a member of the population
            %   powerMeter : the powermeter object.
            
            %Module
            imagesc(individual); %Display the individual on the figure.
            axis off;
            result = object.powerMeter_.getCurrentValue(individual); 
       end
        
       function result = get.ratings(object)
          %Gets the ratings of the population
          % @object : the current populatino for which the rating is
          % sought.
          
          %Module
          result = object.ratings_();
       end
       
       function result = get.individuals(object)
          %Gets the ratings of the population
          % @object : the current populatino for which the individuals is
          % sought.
          
          %Module
          result = object.individuals_();
       end
       
       function result = get.powerMeter(object)
           %Gets the powermeter object from the population.
           % @object : the current populatino for which the powermeter is
           % sought.
           
           %Module
           result = powerMeter_;
       end
       
       function result = bestValue(object)
           %Returns the highest rating obtained by a member of the
           %population.
           %    @object: the population for which the best rating is
           %    sought.
           
           
           %Module
           result = object.ratings_(1);
       end
       
    function addToFirst(object, object2)
           %This function combines two populations. Result is placed in
           %the object making the call.
           %    @object : the first population.
           %    @object2: the second population.
           
           %If the new individual's rating is better than the worst rating 
           %in the population, add that individual to the population and
           %delete the old individual.
           if(isa(object, 'Population') && isa(object2, 'Population') && length(object.ratings_) == length(object2.ratings))
               %Declaraton and definition of variables
               %-->newRatings: the ratings of both objects in descending order.
               %-->newIndex: the index of the individuals inside.
               [newRatings, newIndex] = sort([object.ratings_, object2.ratings_], 'descend');
               %-->newIndividuals: the combination of both population.
               newIndividuals(:,:,:) = zeros(object.m, object.n, length(object.ratings_));
               actualRatings = zeros(floor(length(newIndex)/2)); %The new series of ratings
               actualIndex = 1; %The index of the new population.
               %Module
               for i= 1:floor(length(newIndex))
                   if(newIndex(i) <= floor(length(newIndex)/2))
                       if(actualIndex==1 || ~sum(newRatings(i)==actualRatings(1:(actualIndex-1))))
                            newIndividuals(:,:,actualIndex) = object.individuals_(:,:,newIndex(i));
                            actualRatings(actualIndex) = newRatings(i);
                            actualIndex = actualIndex + 1;
                           
                       end
                   else
                       if(actualIndex==1 || ~sum(newRatings(i)==actualRatings(1:(actualIndex-1))))
                            newIndividuals(:,:,actualIndex) = object2.individuals_(:,:,mod(newIndex(i), size((newIndividuals),3))+1);
                            actualRatings(actualIndex) = newRatings(i);
                            actualIndex = actualIndex + 1;
                       end
                   end
                   if (actualIndex == floor(length(newIndex)/2))
                      break; 
                   end
               end
               object.individuals_(:,:,:) = newIndividuals;
               object.ratings_ = actualRatings(1:size((newIndividuals),3));
               object.index = mod(newIndex(1:size((newIndividuals),3)), size(newIndividuals, 3));
           else
               errorInfo.message = 'Program failed because values passed to populations addToFirst method were not Population objects or the length of the objects is not equal!';
               errorInfo.identifier = 'Population:IncorrectValueTypes';
               error(errorInfo);
           end
       end
       
    function result = mate(object)
           %A child is created within the population.
           %    object : the population from which the child is created.
           %    result : returns the power outputed by the child.
            
           %Module
           %Select individuals for mating.
           selection1 = generateRandomValue(object);
           selection2 = generateRandomValue(object);
           while (selection1 == selection2)
               selection1 = generateRandomValue(object);
               selection2 = generateRandomValue(object);
           end
           selection1=1;
           %Obtaining individuals from population.
           parent1 = object.getIndividual(selection1);
           parent2 = object.getIndividual(selection2);
           display(parent1);
           %Select values genes that will be taken from those individuals.
           %to produce a child.
           parent1Genes = randi([0, 1], [object.m, object.n]);
           parent2Genes = ~parent1Genes;
           %Create child of selected parents.
           child = parent1Genes.*parent1 + parent2Genes.*parent2;
           %Add individual to the population if it has a better rating than
           %the worst rating amongst the population.
           ratingOfChild = rate(object, child);            
           add(object, child, ratingOfChild);
           result = ratingOfChild;
       end
   end
   methods (Access = private)
       function result = generateRandomValue(object)
          %Generates a random value between 1 and the size of the
          %population.
          %     @object : the current population for which a random
          %     individual is sought.
           
          %Module
          result = floor(rand*rand*(size(object.individuals_(:,:,:), 3)) + 1); 
       end
       
       function result = getIndividual(object, index)
           %Gets an individual in the population.
           %    @object: the population in which an individual is sought.
           %    @index: the index of the individual that is sought.
           
           result = object.individuals_(:, :, object.index(index));
       end
       
       function add(object, individual, newIndividualsRating)
           %Rate the new individual and determine it's location in the
           %population's hierarchy depending on the rating it obtained.
           %    @object: The current population.
           %    @individudal: The individual that will be added to the
           %    group.
           %    @newIndividualsRating: The individual to be added's rating.
           
           %Module
           [newRatings, newIndex] = sort([object.ratings_, newIndividualsRating], 'descend');
            %If the new individual's rating is better than the worst rating 
            %in the population, add that individual to the population and
            %delete the old individual.
            display(num2str(object.ratings_));
            pause(0.05);
           if (newRatings(length(newRatings)) ~= newIndividualsRating)
               object.individuals_(:,:,newIndex(length(newIndex))) = individual;
               object.ratings_(length(object.ratings_)) = newIndividualsRating;
               [object.ratings_, object.index] = sort(object.ratings_, 'descend');
           end
       end
   end
end