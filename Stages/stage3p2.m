% function stage3p2
%
% Third stage part two of the cube. Solve for top layer side pieces.
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
% See also: stage3p1.m, topsideBFS.m

function [cube,cubeSolved,total_algo] = stage3p2(cube,cubeSolved,plotLogic)
total_algo = [];
[cornersSolve, sidesSolve] = getLocations(cubeSolved);

algo_side_R_d = "L F R' F' L' R U R U' R'";
algo_side_R_u = invAlgo(algo_side_R_d);
algo_side_L_d = "R' F' L F R L' U' L' U L";
algo_side_L_u = invAlgo(algo_side_L_d);

index_goal = 6;
color_goal = sidesSolve(index_goal,:);
[~,sides] = getLocations(cube);
index_tmp = getRowLoc(color_goal,sides);
color_tmp = sides(index_tmp,:);

if index_tmp == 9
    if isequal(color_goal,color_tmp)
        cube = Y(Y(cube));
        cube = doAlgorithm(cube,algo_side_R_u);
        cube = Y(Y(cube));
        total_algo = join([total_algo, "Y2", algo_side_R_u, "Y2"]); % record step
    else
        cube = doAlgorithm(cube,algo_side_L_d);
        total_algo = join([total_algo, algo_side_L_d ]); % record step
    end
elseif index_tmp == 5
    if isequal(color_goal,color_tmp)
        cube = Y(Y(cube));
        cube = doAlgorithm(cube,algo_side_L_u);
        cube = Y(Y(cube));
        cube = doAlgorithm(cube,algo_side_R_d);
        total_algo = join([total_algo, "Y2", algo_side_L_u, "Y2",algo_side_R_d]); % record step
    else
        cube = doAlgorithm(cube,algo_side_R_u);
        total_algo = join([total_algo,algo_side_R_u]); % record step
    end
elseif index_tmp == 10
    if isequal(color_goal,color_tmp)
        cube = Y(Y(cube));
        cube = doAlgorithm(cube,algo_side_L_u);
        cube = Y(Y(cube));
        total_algo = join([total_algo, "Y2", algo_side_L_u, "Y2"]); % record step
    else
        cube = doAlgorithm(cube,algo_side_R_d);
        total_algo = join([total_algo, algo_side_R_d]); % record step
    end
elseif index_tmp == 6 && ~isequal(color_goal,color_tmp)
    cube = doAlgorithm(cube,algo_side_R_u);
    cube = Y(Y(cube));
    cube = doAlgorithm(cube,algo_side_L_u);
    cube = Y(Y(cube));
    total_algo = join([total_algo, algo_side_R_u, "Y2", algo_side_L_u, "Y2" ]); % record step
end

cube = Y(cube);
total_algo = join([total_algo, "Y" ]); % record step
cubeSolved = Y(cubeSolved);
[cornersSolve, sidesSolve] = getLocations(cubeSolved);

if plotLogic == 1
    plotcube(cube)
end

[cube, algo_out] = topsideBFS(cube,sidesSolve);
if plotLogic == 1
    plotcube(cube)
end
total_algo = join([total_algo, algo_out ]); % record step


end