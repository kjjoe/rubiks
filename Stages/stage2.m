% function stage2
%
% Second stage of the cube. Solve the middle side pieces. Flip the cube
% upside down at the end.
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
% See also: stage1p2.m, stage3p1.m

function [cube,cubeSolved,total_algo] = stage2(cube,cubeSolved,plotLogic)
total_algo = [];

algo_mid_right = "U R U' R' U' F' U F";
algo_mid_left = "U' L' U L U F U' F'";

for yrotate = 1:4
    cube = Y(cube);
    cubeSolved = Y(cubeSolved);
    total_algo = join([total_algo, "Y"]); % record step
    [~, sidesSolve] = getLocations(cubeSolved);
    
    
    index_goal = 4;
    color_goal = sidesSolve(index_goal,:);
    [~,sides] = getLocations(cube);
    index_tmp = getRowLoc(color_goal,sides);
    color_tmp = sides(index_tmp,:);

    if index_tmp == 4 && isequal(color_tmp,color_goal)
        % done
    elseif index_tmp == 4
        cube = doAlgorithm(cube,algo_mid_right);
        cube = U(U(cube));
        cube = doAlgorithm(cube,algo_mid_right);
        
        total_algo = join([total_algo, algo_mid_right, "U2", algo_mid_right]); % record step
    elseif index_tmp == 2
        cube = doAlgorithm(cube,algo_mid_left);
        total_algo = join([total_algo, algo_mid_left]); % record step
        
        [~,sides] = getLocations(cube);
        index_tmp = getRowLoc(color_goal,sides);
        color_tmp = sides(index_tmp,:);
        if isequal(color_tmp,color_goal)
            cube = U(cube);
            cube = Y(cube);
            cube = doAlgorithm(cube,algo_mid_left);
            cube = Y(cube,1);
            total_algo = join([total_algo, "U Y", algo_mid_left, "Y'"]); % record step
        else
            cube = U(U(cube));
            cube = doAlgorithm(cube,algo_mid_right);
            total_algo = join([total_algo, "U2", algo_mid_right]); % record step
        end
    elseif index_tmp == 3
        cube = Y(cube);
        cube = doAlgorithm(cube,algo_mid_right);
        cube = Y(cube,1);
        total_algo = join([total_algo, "Y", algo_mid_right, "Y'"]); % record step
        
        
        [~,sides] = getLocations(cube);
        index_tmp = getRowLoc(color_goal,sides);
        color_tmp = sides(index_tmp,:);

        if isequal(color_tmp,color_goal)
            cube = U(U(cube));
            cube = Y(cube);
            cube = doAlgorithm(cube,algo_mid_left);
            cube = Y(cube,1);
            total_algo = join([total_algo, "U2 Y", algo_mid_left, "Y'"]); % record step
        else
            cube = U(cube,1);
            cube = doAlgorithm(cube,algo_mid_right);
            total_algo = join([total_algo, "U'", algo_mid_right]); % record step
        end

    elseif index_tmp == 1
        cube = Y(Y(cube));
        cube = doAlgorithm(cube,algo_mid_right);
        cube = Y(Y(cube));
        total_algo = join([total_algo, "Y2", algo_mid_right, "Y2"]); % record step
        
        
        [~,sides] = getLocations(cube);
        index_tmp = getRowLoc(color_goal,sides);
        color_tmp = sides(index_tmp,:);
        if isequal(color_tmp,color_goal)
            cube = U(cube,1);
            cube = Y(cube);
            cube = doAlgorithm(cube,algo_mid_left);
            cube = Y(cube,1);
            total_algo = join([total_algo, "U' Y", algo_mid_left, "Y'"]); % record step
        else
            cube = doAlgorithm(cube,algo_mid_right);
            total_algo = join([total_algo, algo_mid_right]); % record step
        end
        
    elseif index_tmp == 5
        if isequal(color_tmp,color_goal)
            cube = U(cube);
            cube = Y(cube);
            cube = doAlgorithm(cube,algo_mid_left);
            cube = Y(cube,1);
            total_algo = join([total_algo, "U Y", algo_mid_left, "Y'"]); % record step
        else
            cube = U(U(cube));
            cube = doAlgorithm(cube,algo_mid_right);
            total_algo = join([total_algo, "U2", algo_mid_right]); % record step
        end
    elseif index_tmp == 6
        if isequal(color_tmp,color_goal)
            cube = U(cube,1);
            cube = Y(cube);
            cube = doAlgorithm(cube,algo_mid_left);
            cube = Y(cube,1);
            total_algo = join([total_algo, "U' Y", algo_mid_left, "Y'"]); % record step
            
        else
            cube = doAlgorithm(cube,algo_mid_right);
            total_algo = join([total_algo,algo_mid_right]); % record step
        end
    elseif index_tmp == 9
        if isequal(color_tmp,color_goal)
            cube = U(U(cube));
            cube = Y(cube);
            cube = doAlgorithm(cube,algo_mid_left);
            cube = Y(cube,1);
            total_algo = join([total_algo, "U2 Y", algo_mid_left, "Y'"]); % record step
        else
            cube = U(cube,1);
            cube = doAlgorithm(cube,algo_mid_right);
            total_algo = join([total_algo, "U'", algo_mid_right]); % record step
        end
    elseif index_tmp == 10
        if isequal(color_tmp,color_goal)
            cube = Y(cube);
            cube = doAlgorithm(cube,algo_mid_left);
            cube = Y(cube,1);
            total_algo = join([total_algo, "Y", algo_mid_left, "Y'"]); % record step
        else
            cube = U(cube);
            cube = doAlgorithm(cube,algo_mid_right);
            total_algo = join([total_algo, "U", algo_mid_right]); % record step
        end
    end
end
if plotLogic == 1
    plotcube(cube)
end

end
