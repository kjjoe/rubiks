% function stage3p1
%
% Third stage part one of the cube. Solve for the top layer corners first. 
%
% input:  
%    - cube:       current state of the cube
%    - cubeSolved: desired cube given orientation
%    - plotLogic:  plot the cube or not
%
% output: 
%    - cube:       output state of the cube
%    - cubeSolved: output state of the solved cube. changes if rotated
%    - total_algo: algorithm in this stage
%
% See also: stage2.m, stage3p2.m

function [cube,cubeSolved,total_algo] = stage3p1(cube,cubeSolved,plotLogic)
total_algo = [];
[cornersSolve, sidesSolve] = getLocations(cubeSolved);

algo_rot_cc = "U R U' L' U R' U' L";
algo_rot_c  = invAlgo(algo_rot_cc);

index_goal = 4;
color_goal = cornersSolve(index_goal,:);
[corners,sides] = getLocations(cube);
index_tmp = getRowLoc(color_goal,corners);
color_tmp = corners(index_tmp,:);

if index_tmp == 3
    cube = U(cube);
    total_algo = join([total_algo, "U"]); % record step
elseif index_tmp == 1
    cube = U(U(cube));
    total_algo = join([total_algo, "U2"]); % record step
elseif index_tmp == 2
    cube = U(cube,1);
    total_algo = join([total_algo, "U'"]); % record step
end
if plotLogic == 1
    plotcube(cube)
end

match = checkTopCorner(cube,cornersSolve);
steps = 0;
while match ~= 4 && steps < 10
    if match == 2
        cube = U(cube,1);
        cube = doAlgorithm(cube,algo_rot_cc);
        cube = U(U(cube));
        total_algo = join([total_algo, "U'", algo_rot_cc, "U2"]); % record step
    elseif match == 1
        cube = doAlgorithm(cube,algo_rot_cc);
        total_algo = join([total_algo, algo_rot_cc]); % record step
    end
    match = checkTopCorner(cube,cornersSolve);
    steps = steps + 1;
end
if steps == 10
    disp('stuck ...?')
end

for yrotate = 1:4
    cube = U(cube);
    total_algo = join([total_algo, "U"]); % record step
    cubeSolved = U(cubeSolved);
    [cornersSolve, sidesSolve] = getLocations(cubeSolved);
    
    plotcube(cube)
    index_goal = 4;
    color_goal = cornersSolve(index_goal,:);
    goal = {color_goal,index_goal};
    
    algo_rep = "R' D' R D";
    correctCorner = 0;
    steps = 0;
    while correctCorner == 0 && steps < 6        
        [corners_tmp, ~] = getLocations(cube);
        index_tmp = getRowLoc(color_goal,corners_tmp);
        color_tmp = corners_tmp(index_tmp,:);
        if isequal(color_tmp,color_goal)
            correctCorner = 1;
        else
            cube = doAlgorithm(cube,algo_rep);
            total_algo = join([total_algo, algo_rep]); % record step
        end
        steps = steps+1;
    end
end

if plotLogic == 1
    plotcube(cube)
end