%% rubiks cube
% Kevin Joe
% 3x3
clear all
close all

trials = 1000;
nummoves = zeros(trials,1);
nummovesReduced = zeros(trials,1);
plotLogic = 0;

addpath('Algorithms')
addpath('GetInfo')
addpath('Movement')
addpath('Plot')
addpath('Stages')

%% solved cube start

for trialnum =  544
    
cube = newCube();
cubeSolved = cube;

if plotLogic == 1
    plotcube(cube);
end

[cornersSolve, sidesSolve] = getLocations(cube);

% view(-70,20)


%% mix up
cube = cubeSolved;
pausetime = 0.01;
[cube,algo] = shuffle(cube,trialnum);

if plotLogic == 1
    plotcube(cube);
end

total_algo = [];

%% stage 1.1 the cross
rot = ['X','Y','Z'];

tic
[cube,cubeSolved,algo1p1] = stage1p1(cube,cubeSolved,plotLogic);
total_algo = join([total_algo, algo1p1]);
toc
% 
% for i = 1:3
%     movefunc = str2func(rot(i));
%     for j = 1:2
%         if j == 1
%             cube_tmp = movefunc(cube); 
%         else
%             cube_tmp = movefunc(cube,1);
%         end
% 
%         [~,~,algo_tmp] = stage1p1(cube_tmp,cubeSolved,plotLogic);
%         length(split(algo_tmp))
% %         total_algo = join([total_algo, algo1p1]);
%     end
% end



%% stage 1.2 the corners
tic
[cube,cubeSolved,algo1p2] = stage1p2(cube,cubeSolved,plotLogic);
total_algo = join([total_algo, algo1p2]);
toc
%% Stage 2: middle sides;
tic
[cube,cubeSolved,algo2] = stage2(cube,cubeSolved,plotLogic);
total_algo = join([total_algo, algo2]);
toc
%% stage 3.1 corners
tic
[cube,cubeSolved,algo3p1] = stage3p1(cube,cubeSolved,plotLogic);
total_algo = join([total_algo, algo3p1]);
toc
%% stage 3.2 getting one side correct
tic
[cube,cubeSolved,algo3p2] = stage3p2(cube,cubeSolved,plotLogic);
total_algo = join([total_algo, algo3p2]);
toc

%% Test if solved

if isequal(cubeSolved,cube)
    nummoves(trialnum) = size(split(total_algo),1);
    fprintf("Trial #%d: Solved in %d moves\n", trialnum, size(split(total_algo),1))
else
    nummoves(trialnum) = -1;
    fprintf("Trial #%d: Did not solve\n",trialnum);
end
    
%% test reduceAlgo
cube = newCube();
[cube,~] = shuffle(cube,trialnum);
algo_red = reduceAlgo(total_algo);
cube_red = doAlgorithm(cube,algo_red);
if isequal(cubeSolved,cube_red)
    nummovesReduced(trialnum) = size(split(algo_red),1);
    fprintf('Trial #%d: Reduced Algorithm Solved in %d moves\n',trialnum,size(split(algo_red),1))
else
    fprintf('Trial #%d: fail\n',trialnum)
end

%% animation?? 

animateSolution(algo_red, trialnum)


% to do: make it so that each stage has input so that it knows which side
% and order to solve things in. Also have a way parse an algorithm and not
% include cube rotations as "moves". In addition, reduce algorithm to
% remove doubles like Y then Y' immediately. 



end