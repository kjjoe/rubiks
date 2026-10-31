%% generate training data
addpath('Algorithms')
addpath('GetInfo')
addpath('Movement')
addpath('Plot')
addpath('Stages')

seed = 1;
rng(seed);

cube = newCube();
train_size = 10000;
train_data = zeros(5,5,5,train_size);
train_label = zeros(train_size,1);
doublesFlag = 0;

parfor i = 1:train_size
    numshuffle = randi([0,10]);
    [cube_shuffle,algo_tmp] = shuffle(cube,[],numshuffle,doublesFlag);
    algo = reduceAlgo(algo_tmp);
    
    train_data(:,:,:,i) = cube_shuffle;
    if isempty(algo)
        train_label(i) = 0;
    else
        train_label(i) = size(split(algo),1);
    end
end

% save('training_data.mat')
%% rubiks cube

rng(1)
% Train options
maxEpochs = 100; % probably sufficient
miniBatchSize = 512;
options = trainingOptions('adam', ...
    'ExecutionEnvironment','gpu',...
    'GradientThreshold',1, ...
    'InitialLearnRate', 0.05, ... 
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'Shuffle','every', ...
    'Verbose',0, ...
    'Plots','training-progress');

layers = [
        imageInputLayer( size(train_data(:,:,:,1)) )
        fullyConnectedLayer(128)
        reluLayer
        fullyConnectedLayer(128)
        reluLayer
        fullyConnectedLayer(128)
        reluLayer
        fullyConnectedLayer(128)
        reluLayer
        fullyConnectedLayer(32)
        reluLayer
        fullyConnectedLayer(8)
        reluLayer
        fullyConnectedLayer(1)
        regressionLayer
        ];

net = trainNetwork(train_data,train_label,layers,options);
    
    
%% generate test data

rng(11);

cube = newCube();
test_size = 1000;
test_data = zeros(5,5,5,test_size);
test_label = zeros(test_size,1);

for i = 1:test_size
    numshuffle = randi([0,10]);
    [cube_shuffle,algo_tmp] = shuffle(cube,[],numshuffle,doublesFlag);
    algo = reduceAlgo(algo_tmp);
    
    test_data(:,:,:,i) = cube_shuffle;
    if isempty(algo)
        test_label(i) = 0;
    else
        test_label(i) = size(split(algo),1);
    end
end

test_predict = predict(net,test_data);


%% using net to possible solve cube?
close all
rng(13)

cube_solved = newCube();
[cube_shuffle,algo_tmp] = shuffle(cube_solved,[], 5 ,doublesFlag);

cube_input = cube_shuffle;
steps = 0;
algo_model = [];
moveset = split("F F' B B' L L' R R' U U' D D'");

while ~isequal(cube_input,cube_solved) && steps < 10
    cube_next = zeros(5,5,5,12);
    for mindex = 1:12
        
        
        movefunc = str2func(moveset{mindex}(1));
        
        if length(moveset{mindex}) == 2 
            cube_next(:,:,:,mindex) = movefunc(cube_input, 1);
        else
            cube_next(:,:,:,mindex) = movefunc(cube_input);
        end
    end
    
    error_val = predict(net,cube_next);
    [m,mi] = sort(error_val);
    cube_input = cube_next(:,:,:,mi(1));
    
    algo_model = join([algo_model, moveset(mi(1))]);
    
    steps = steps+1;
end

animateSolution(algo_model, cube_shuffle)

























