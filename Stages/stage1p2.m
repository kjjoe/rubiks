% function stage1p2
%
% First stage part 2 of solving the cube. After solving the cross, apply
% this method to solve the corners of the top layer.
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
% See also: stage1p1.m, stage2.m, getRowLoc.m

function  [cube,cubeSolved,total_algo] = stage1p2(cube,cubeSolved,plotLogic)
total_algo = [];

for yrotate = 1:4
    cube = Y(cube);
    total_algo = join([total_algo,"Y"]); % record step
    cubeSolved = Y(cubeSolved);
    [cornersSolve, ~] = getLocations(cubeSolved);
    
    if plotLogic == 1
        plotcube(cube)
    end
    
    index_goal = 4;
    color_goal = cornersSolve(index_goal,:);
    goal = {color_goal,index_goal};
    
    [corners, ~] = getLocations(cube);
    index_root = getRowLoc(color_goal,corners);
    color_root = corners(index_root,:);
    if index_root < 5 && index_root ~= index_goal
        if index_root == 1
            algo_tmp = "L' D' L";
        elseif index_root == 2
            algo_tmp = "L D L'";
        elseif index_root == 3 
            algo_tmp = "B' D' B";
        else
            algo_tmp = "R' D' R";
        end
        cube = doAlgorithm(cube,algo_tmp);
        total_algo = join([total_algo, algo_tmp]); % record step
    end
    
    if plotLogic == 1
        plotcube(cube)
    end
    
    [corners, ~] = getLocations(cube);
    index_root = getRowLoc(color_goal,corners);
    color_root = corners(index_root,:);

    if index_root ~= index_goal+4 && index_root > 4
        lowerPos = 0;
        cube_tmp = cube;
        steps = 0;
        while lowerPos == 0 && steps < 3
            cube_tmp = D(cube_tmp);
            total_algo = join([total_algo, "D"]); % record step
            [corners_tmp, ~] = getLocations(cube_tmp);
            index_tmp = getRowLoc(color_goal,corners_tmp);
            if index_tmp == index_goal + 4
                cube = cube_tmp;
                lowerPos = 1;
            end
            steps = steps + 1;
        end
    end
    if plotLogic == 1
        plotcube(cube)
    end

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
    
    if plotLogic == 1
        plotcube(cube)
    end
end

% stage 1 part 3
cube = doAlgorithm(cube,"Z2");
total_algo = join([total_algo, "Z2"]); % record step
cubeSolved = doAlgorithm(cubeSolved,"Z2");

if plotLogic == 1
    plotcube(cube)
end



end