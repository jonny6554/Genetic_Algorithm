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
       size; %The number of individuals in the current population.
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
       PAUSE_BETWEEN_DISPLAY = 0.01; %Pause time between display of figures.
       MUTATION_FACTOR = 100;    %This value indicates, in percentage, the number of values that will be mutated inside a child.
       MUTATION_FREQUENCY = 100; %This value indicates, in percentage, how frequently a child will receive a mutation.
       POWER_OF_RANDOM_GENERATOR =2; %The power to which the random value generated is put.
       NUMBER_OF_CHILDREN = 20; %The number of children per permutation of the population.
       BEST_CHILDREN_INSERTED = 1; %The number of children generated during permutation that are inserted into the population.
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
           object.size = size;

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

       function result = get.ratings(object)
          %Gets the ratings of the population
          % @object : the current populatino for which the rating is
          % sought.
          
          %Module
          result = object.ratings_;
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
           result = object.powerMeter_;
       end
       
       function result = getbestValue(object)
           %Returns the highest rating obtained by a member of the
           %population.
           %    @object: the population for which the best rating is
           %    sought.
           
           
           %Module
           result = object.ratings_(1);
       end
       
       function result = rate(object, individual)
            %Rates an individual of the population.
            %   individual : a member of the population
            %   powerMeter : the powermeter object.

            %Module
            pause(Population.PAUSE_BETWEEN_DISPLAY);
            figure(object.window);
            imagesc(individual); %Display the individual on the figure.
            axis off;
            result = getCurrentValue(object.powerMeter_, individual); 
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
               newIndividuals(:,:,:) = zeros(object.m, object.n, object.size);
               actualRatings = zeros(floor(length(newIndex)/2)); %The new series of ratings
               actualIndex = 1; %The index of the new population.
               %Module
               display(num2str(object.ratings_));
               for i= 1:floor(length(newIndex))
                   if(newIndex(i) <= floor(length(newIndex)/2))
                       if(actualIndex==1 || ~sum(newRatings(i)==actualRatings(1:(actualIndex-1))))
                            newIndividuals(:,:,actualIndex) = object.individuals_(:,:,newIndex(i));
                            actualRatings(actualIndex) = newRatings(i);
                            actualIndex = actualIndex + 1;
                       end
                   else
                       if(actualIndex==1 || ~sum(newRatings(i)==actualRatings(1:(actualIndex-1))))
                            newIndividuals(:,:,actualIndex) = object2.individuals_(:,:,mod(newIndex(i), object.size)+1);
                            actualRatings(actualIndex) = newRatings(i);
                            actualIndex = actualIndex + 1;
                       end
                   end
                   if (actualIndex == (object.size+1))
                       display(num2str(i));
                       display('done');
                      break; 
                   end
               end
               object.individuals_(:,:,:) = newIndividuals;
               object.ratings_ = actualRatings(1:object.size);
               object.index = mod(newIndex(1:object.size), object.size);
               display(['Add to first', num2str(actualRatings(1:object.size))]);
           else
               errorInfo.message = 'Program failed because values passed to populations addToFirst method were not Population objects or the length of the objects is not equal!';
               errorInfo.identifier = 'Population:IncorrectValueTypes';
               error(errorInfo);
           end
       end
       
       function result = permutate(object)
           %A child is created within the population.
           %    object : the population from which the child is created.
           %    result : returns the power outputed by the child.
           children = zeros(object.m, object.n, Population.NUMBER_OF_CHILDREN); %The children generated during permutation
           ratings = zeros(1, Population.NUMBER_OF_CHILDREN);
           %Module
           %Select individuals for mating.
           for i=1:Population.NUMBER_OF_CHILDREN
               selection1 = generateRandomValue(object);
               selection2 = generateRandomValue(object);
               while (selection1 == selection2)
                   selection1 = generateRandomValue(object);
                   selection2 = generateRandomValue(object);
               end

               %Obtaining individuals from population.
               parent1 = getIndividual(object, selection1);
               parent2 = getIndividual(object, selection2);

    %            if (rand <= 0) %Randomly insert a parent sometimes. (Currently 0% of the time)
    %                parent2 = randi(Population.MAXIMUM_PIXEL_VALUE - Population.MINIMUM_PIXEL_VALUE, object.m, object.n);
    %            end
               %(SELECTION) Select values genes that will be taken from those individuals.
               %to produce a child.
               parent1Genes = randi([0, 1], [object.m, object.n]);
               parent2Genes = ~parent1Genes;

               %(CROSSOVER)Create child of selected parents.
               child = parent1Genes.*parent1 + parent2Genes.*parent2;

               %(MUTATION)Mutate the child
               if (rand <= (Population.MUTATION_FREQUENCY/100))
                   child = mutate(object, child);
               end

               %(EVALUATION)Add individual to the population if it has a better rating than
               %the worst rating amongst the population.
               ratings(i) = rate(object, child);
               children(:,:,i) = child;
           end
           [ratings, childIndex] = sort(ratings, 'descend');
           display(num2str(ratings));
           for i = 1:Population.BEST_CHILDREN_INSERTED
              add(object, children(:,:,childIndex(i)), ratings(i)); 
           end
           result = ratings(1:Population.BEST_CHILDREN_INSERTED);
       end
   end
   methods (Access = private)
       function result = mutate(object, child)
           %This function arbitrarily changes a percentage of the value in
           %a given matrix.
           %    @object : the current population which is making the call
           %    for a mutation
           %    @child : the matrix which will be mutated.
           %    @result : the mutated version of the variable child.
           
           %Module
           %Mutates a given matrix. Call this function only sometimes
           amountOfMutation = floor(object.m*object.n*(Population.MUTATION_FACTOR/100)); %The number of individuals that will be mutated.
           completedMutations = 0; %Indicates the total number of successful mutations.
           %Module
           while(amountOfMutation < completedMutations)
               randomM = randi(object.m);
               randomN = randi(object.n);
               randomM2 = randi(object.n);
               randomN2 = randi(object.n);
               child(randomM, randomN) = child(randomM2, randomN2);
               completedMutations = completedMutations + 1;
           end
           result = child;
       end
       
       function result = generateRandomValue(object)
          %Generates a random value between 1 and the size of the
          %population.
          %     @object : the current population for which a random
          %     individual is sought.
           
          %Module
          result = floor(rand^Population.POWER_OF_RANDOM_GENERATOR*(object.size) + 1); 
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
            display(['The new individuals rating is ', num2str(newIndividualsRating), '.']);
            display(num2str(object.ratings_));
           if (newRatings(length(newRatings)) ~= newIndividualsRating)
               object.individuals_(:,:,newIndex(length(newIndex))) = individual;
               object.ratings_(object.size) = newIndividualsRating;
               [object.ratings_, object.index] = sort(object.ratings_, 'descend');
           end
       end
   end
end