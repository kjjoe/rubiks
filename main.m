%% rubiks cube
% Kevin Joe
% 3x3
clear all
close all

trials = 1000;
nummoves = zeros(trials,1);
plotLogic = 0;

addpath('Algorithms')
addpath('GetInfo')
addpath('Movement')
addpath('Plot')

%% solved cube start

for trialnum =  14 %893
tic
    
cube = newCube();
cubeSolved = cube;

if plotLogic == 1
    plotcube(cube);
end

[cornersSolve, sidesSolve] = getLocations(cube);

view(-70,20)


%% mix up
cube = cubeSolved;
pausetime = 0.01;
[cube,algo] = shuffle(cube,trialnum);

if plotLogic == 1
    plotcube(cube);
end


%% stage 1.1 the cross
cross = [5,6,9,10];
exitCross = 0;
steps = 0;
total_algo = [];
while exitCross == 0 && steps < 10
    checkCross = 0;
    cross = cross(randperm(length(cross)));
    for i = 1:4
        index_goal = cross(i);
        [cube, algo_out] = sideBFS(cube,index_goal,sidesSolve);
        if isempty(algo_out)
            checkCross = checkCross + 1;
        else
            total_algo = [total_algo, algo_out];
        end
    end
    
    if checkCross == 4
        exitCross = 1;
    end
    steps = steps+1;
    if plotLogic == 1
	     plotcube(cube);
    end
end
total_algo = join(total_algo);

%% stage 1.2 the corners
for yrotate = 1:4
    cube = Y(cube);
    total_algo = join([total_algo,"Y"]); % record step
    cubeSolved = Y(cubeSolved);
    [cornersSolve, sidesSolve] = getLocations(cubeSolved);
    
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

%% Stage 1.3: Flip Cube
cube = doAlgorithm(cube,"Z2");
total_algo = join([total_algo, "Z2"]); % record step
cubeSolved = doAlgorithm(cubeSolved,"Z2");
[cornersSolve, sidesSolve] = getLocations(cubeSolved);
if plotLogic == 1
    plotcube(cube)
end
%% Stage 2: middle sides;
algo_mid_right = "U R U' R' U' F' U F";
algo_mid_left = "U' L' U L U F U' F'";

for yrotate = 1:4
    cube = Y(cube);
    cubeSolved = Y(cubeSolved);
    total_algo = join([total_algo, "Y"]); % record step
    [cornersSolve, sidesSolve] = getLocations(cubeSolved);
    
    
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

%% stage 3.1 corners
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

%% stage 3.2 getting one side correct
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


%% 3.3 finish the remaining 3 sides

[cube, algo_out] = topsideBFS(cube,sidesSolve);
if plotLogic == 1
    plotcube(cube)
end
total_algo = join([total_algo, algo_out ]); % record step

%% total plot
toc


if isequal(cubeSolved,cube)
    nummoves(trialnum) = size(split(total_algo),1);
    fprintf("Solved #%d in %d moves\n", trialnum, size(split(total_algo),1))
else
    nummoves(trialnum) = -1;
    fprintf("Did not solve\n");
end
    
end

%% animation?? 

animateSolution(total_algo, trialnum)









