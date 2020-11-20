%% rubiks cube
% Kevin Joe
% 3x3
clear all
close all

trials = 1000;
nummoves = zeros(trials,1);

%% solved cube start
for trialnum = 893
tic
    
cube = newCube();
cubeSolved = cube;
%plotcube(cube);

[cornersSolve, sidesSolve] = getLocations(cube);
% %%
% cube = D(cube);
% %plotcube(cube)
view(-70,20)

% cube = R(cube)
% %plotcube(cube);
% [corners, sides] = getLocations(cube)


%% mix up
cube = cubeSolved;
pausetime = 0.01;
[cube,algo] = shuffle(cube,trialnum);
% plotcube(cube)s;



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
%         plotcube(cube);
    end
    
    if checkCross == 4
        exitCross = 1;
    end
    steps = steps+1;
%     plotcube(cube);
end
total_algo = join(total_algo);
% plotcube(cube)


%% stage 1.2 the corners
for yrotate = 1:4
    cube = Y(cube);
    total_algo = join([total_algo,"Y"]); % record step
    cubeSolved = Y(cubeSolved);
    [cornersSolve, sidesSolve] = getLocations(cubeSolved);
    
    %plotcube(cube)
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
    %plotcube(cube)
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
    %plotcube(cube)

    %
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
    
    plotcube(cube)
end

%% Stage 1.3: Flip Cube
cube = doAlgorithm(cube,"Z2");
total_algo = join([total_algo, "Z2"]); % record step
cubeSolved = doAlgorithm(cubeSolved,"Z2");
[cornersSolve, sidesSolve] = getLocations(cubeSolved);
%plotcube(cube)

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
%plotcube(cube);

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
%plotcube(cube);
%
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

%
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

% plotcube(cube)

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

% cubetmp = doAlgorithm(cube,algo_side_L_c);
cube = Y(cube);
total_algo = join([total_algo, "Y" ]); % record step
cubeSolved = Y(cubeSolved);
[cornersSolve, sidesSolve] = getLocations(cubeSolved);
% plotcube(cube)


%% 3.3 finish the remaining 3 sides

[cube, algo_out] = topsideBFS(cube,sidesSolve);
%plotcube(cube)
total_algo = join([total_algo, algo_out ]); % record step

%% total plot
toc
% cube2 = shuffle(newCube,trialnum);
% cube2 = doAlgorithm(cube2,total_algo,pausetime);
% % plotcube(cubetmp)
% 

    
    if isequal(cubeSolved,cube)
        nummoves(trialnum) = size(split(total_algo),1);
        fprintf("Solved #%d in %d moves\n", trialnum, size(split(total_algo),1))
    else
        nummoves(trialnum) = -1;
        fprintf("Did not solve\n");
    end
    
end



%% animation?? 
makevideo = 0;
if makevideo == 1
    video = VideoWriter('rubiks2.avi');
    video.FrameRate = 60;
    open(video)
end

cube = newCube();
[cube,algo] = shuffle(cube,trialnum);
[colors,faces] = getFaceColors(cube);
piece = cell(27,6);
num = 1;
shifts = zeros(27,3);
for a = -1:1
    for b = 1:-1:-1
        for c = -1:1
            shifts(num,:) = [a,b,c];
            num = num + 1;
        end
    end
end

tic
piece_x = zeros(162,4);
piece_y = zeros(162,4);
piece_z = zeros(162,4);
piece_c = zeros(162,3);
step = 1;
for i = 1:27
    piece(i,:) = onePiece(colors{i},shifts(i,:)');
    for j = 1:6
        piece_x(step,:) = piece{i,j}(1,:);
        piece_y(step,:) = piece{i,j}(2,:);
        piece_z(step,:) = piece{i,j}(3,:);
        piece_c(step,:) = colors{i}(j,:);
        step = step+1;
    end
end
piece_c = reshape(piece_c,[162,1,3]);
patch(piece_x',piece_y',piece_z',piece_c)
axis([-2.5,2.5,-2.5,2.5,-2.5,2.5])
view(-70,20)
toc

pause(0.00001)

if makevideo == 1
    frame = getframe(gcf);
    writeVideo(video,frame);
end

%
output = invAlgo(algo);
algo = convertStringsToChars(total_algo);
moves = split(algo,' ');
for i = 1:length(moves)
    lenmove = length(moves{i});
    movefunc = str2func(moves{i}(1));
    
    incstep = 0.05;
    incrange = incstep:incstep:0.5;
    
    prime = 0; 
    double = 0;
    
    if lenmove == 2
        if moves{i}(2) == "'" 
            prime = 1;
        end
        if moves{i}(2) == '2'
            double = 1;
        end 
    end
    if double == 1
        cube = movefunc(cube);
        cube = movefunc(cube);
        incrange = 2*incrange;
    elseif prime == 1
        cube = movefunc(cube,prime);
        incrange = -incrange;
    else
        cube = movefunc(cube);
    end
    
    switch moves{i}(1)
        case 'D'
            moveface = 1;
            rot = @(theta) [cos(theta), -sin(theta),0; sin(theta),cos(theta),0; 0,0,1];
        case 'F'
            moveface = 2;
            rot = @(theta) [1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];
        case 'R'
            moveface = 3;
            rot = @(theta) [cos(theta),0, sin(theta); 0,1,0; -sin(theta),0,cos(theta)];
        case 'U'
            moveface = 4;
            rot = @(theta) [cos(-theta), -sin(-theta),0; sin(-theta),cos(-theta),0; 0,0,1];
        case 'B'
            moveface = 5;
            rot = @(theta) [1 0 0; 0 cos(-theta) -sin(-theta); 0 sin(-theta) cos(-theta)];
        case 'L'
            moveface = 6;
            rot = @(theta) [cos(-theta),0, sin(-theta); 0,1,0; -sin(-theta),0,cos(-theta)];
        case 'M' % L
            moveface = 7;
            rot = @(theta) [cos(-theta),0, sin(-theta); 0,1,0; -sin(-theta),0,cos(-theta)];
        case 'E' % D
            moveface = 8;
            rot = @(theta) [cos(theta), -sin(theta),0; sin(theta),cos(theta),0; 0,0,1];
        case 'S' % F
            moveface = 9;
            rot = @(theta) [1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];
        case 'X' % R
            moveface = 10;
            rot = @(theta) [cos(theta),0, sin(theta); 0,1,0; -sin(theta),0,cos(theta)];
        case 'Y' % U
            moveface = 11;
            rot = @(theta) [cos(-theta), -sin(-theta),0; sin(-theta),cos(-theta),0; 0,0,1];
        case 'Z' % F
            moveface = 12;
            rot = @(theta) [1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];
            
    end
    
    
    for inc = incrange
%         tic
        clf
        theta = pi * inc;
        rotmat = rot(theta);
        
        piece_x = zeros(162,4);
        piece_y = zeros(162,4);
        piece_z = zeros(162,4);
        piece_c = zeros(162,3);
        step = 1;

        for p = 1:27
            if moveface <= 10
                if  sum(faces(moveface,:) == p) > 0
                    piece(p,:) = onePiece(colors{p},shifts(p,:)', rotmat);
                else
                    piece(p,:) = onePiece(colors{p},shifts(p,:)' );
                end
            else
                piece(p,:) = onePiece(colors{p},shifts(p,:)', rotmat);
            end
            
            for j = 1:6
                piece_x(step,:) = piece{p,j}(1,:);
                piece_y(step,:) = piece{p,j}(2,:);
                piece_z(step,:) = piece{p,j}(3,:);
                piece_c(step,:) = colors{p}(j,:);
                step = step+1;
            end
            
        end
        
        piece_c = reshape(piece_c,[162,1,3]);
        patch(piece_x',piece_y',piece_z',piece_c)
        axis([-2.5,2.5,-2.5,2.5,-2.5,2.5])
        view(-70,20)
        title(moves{i})
%         toc
        
        pause(0.00001)
        if makevideo == 1
            frame = getframe(gcf);
            writeVideo(video,frame);
        end
    end
    
    [colors,faces] = getFaceColors(cube);
    
    
    
end

if makevideo == 1
    close(video);
end


function [colors,faces] = getFaceColors(cube)

    colors = cell(27,1);
    colors(:) = {zeros(6,3)};
    % cube sides 1-6 in order
    faces = zeros(9,9);

    faces(1,:) = 1:3:27; %d
    faces(2,:) = 1:9;    %f
    rr = [7,8,9]; faces(3,:) = [rr, rr+9, rr+18]; %r
    faces(4,:) = 3:3:27;  %u
    faces(5,:) = 19:27;   %b
    ll = [1,2,3]; faces(6,:)  = [ll, ll+9, ll+18]; %l
    
    faces(7,:) = faces(6,:) + 3; % M
    faces(8,:) = faces(1,:) + 2; % E
    faces(9,:) = faces(2,:) + 9; % S

    for a = 1:6
        if a == 1 %d
            cubeface = squeeze(cube(2:4,2:4,5));
            mapface = flip(reshape(faces(1,:),[3,3])');
        elseif a == 2 %f
            cubeface = squeeze(cube(5,2:4,2:4))' ;
            mapface = flip(reshape(faces(2,:),[3,3]));
        elseif a == 3 %r
            cubeface = fliplr(squeeze(cube(2:4,5,2:4))');
            mapface = flipud(reshape(faces(3,:),[3,3]));
        elseif a == 4 %u
            cubeface = squeeze(cube(2:4,2:4,1));
            mapface = flipud(reshape(faces(4,:),[3,3])');
        elseif a == 5 %b
            cubeface = fliplr(squeeze(cube(1,2:4,2:4))' );
            mapface = fliplr(flipud(reshape(faces(5,:),[3,3])));
        elseif a == 6 %l
            cubeface = squeeze(cube(2:4,1,2:4))' ;
            mapface = fliplr(flipud(reshape(faces(6,:),[3,3])));
        end

        for b = 1:9
            colors{ faces(a,b) } (a,:) = num2color(cubeface(find(mapface == faces(a,b),1)));
        end
    end
end

function piece = onePiece(color, shift_dir,R)
    piece = cell(1,6);
    if nargin == 1
        shift_dir = [0; 0; 0];
        R = eye(3);
    elseif nargin == 2
        R = eye(3);
    end

    s = [0,1,1,0; ...
         0,0,1,1; ... 
         0,0,0,0] - 0.5;
    num = 1;
    for z = 0:1
        s(3,:) = s(3,:) + z;
        for k = 0:2
            s_tmp = R * (circshift(s,k,1) +  shift_dir);
%             patch(s_tmp(1,:),s_tmp(2,:),s_tmp(3,:),color(num,:));
            piece{num} = s_tmp;
            num = num+1;
        end
        s(3,:) = s(3,:) - z;
    end
%     axis([-2.5,2.5,-2.5,2.5,-2.5,2.5])
%     view(-70,20)
end





%% function check if corners correct

function match = checkTopCorner(cube,cornersSolve)
    match = 0;
    for i = 1:4
        index_goal = i;
        color_goal = cornersSolve(index_goal,:);
        [corners,~] = getLocations(cube);
        index_tmp = getRowLoc(color_goal,corners);

        if index_tmp == index_goal 
            match = match+1;
        end
    end
end





%% movements
function [cube_out, algo_out] = topsideBFS(cube,sidesSolve)
algo_side_R_d = "L F R' F' L' R U R U' R'";
algo_side_R_u = invAlgo(algo_side_R_d);
algo_side_L_d = "R' F' L F R L' U' L' U L";
algo_side_L_u = invAlgo(algo_side_L_d);


goal = sidesSolve([5,6,10],:);

[~, sides] = getLocations(cube);
root = {sides([5,6,10],:),cube, []};


discovered = cell(48,2);
piece = cell(3,1);
pp = perms(1:3);

step = 1;
for k = 0:7
    f = de2bi(k,3);
    for i = 1:6
        piece{1} = goal(pp(i,1),:);
        piece{2} = goal(pp(i,2),:);
        piece{3} = goal(pp(i,3),:);
        for j = 1:3
            if f(j) == 1
                piece{j} = flip(piece{j});
            end
        end
        statetmp = [piece{1} ; piece{2} ; piece{3}];
        discovered{step,1} = statetmp;
        discovered{step,2} = 0;
        if isequal(statetmp,root{1})
            discovered{step,2} = 1;
        end
        step = step+1;
    end
end

%
Q = [root]; % colors, index, discovered
moveTop = [algo_side_R_d; ... 
           algo_side_R_u; ...
           join(["Y Y",algo_side_L_d,"Y Y"]); ... 
           join(["Y Y",algo_side_L_u,"Y Y"])];

%
while ~isempty(Q)
    v = Q(1,:);
    Q(1,:) = [];

    if isequal(v{1}, goal)
        output = v;
    else
        cube_prev = v{2};
        for i = 1:4 
            cube_tmp = doAlgorithm(cube_prev,moveTop(i));
            [~, sides_tmp] = getLocations(cube_tmp);
            prevmoves = [v{3}; moveTop(i)];
            node = {sides_tmp([5,6,10],:), cube_tmp, prevmoves };

            for k = 1:48
                if isequal(node{1},discovered{k,1})
                    if discovered{k,2} == 0
                        discovered{k,2} = 1;
                        Q = [Q; node];

                    end
                end
            end

        end
    end
end

cube_out = output{2};

if isempty(output{3})
    algo_out = [];
else
    algo_out = join(output{3});
end

plotcube(cube_out)

end


function [cube_out, algo_out] = sideBFS(cube,index_goal,sidesSolve)
    color_goal = sidesSolve(index_goal,:);
    goal = {color_goal,index_goal};

    [~, sides] = getLocations(cube);
    index_root = getRowLoc(color_goal,sides);
    color_root = sides(index_root,:);
    root = {color_root,index_root,cube, []};

    discovered = cell(24,3);
    for i = 1:12
        discovered{i,1} = color_goal;
        discovered{i,2} = i;
        discovered{i,3} = 0;

        discovered{i+12,1} = flip(color_goal);
        discovered{i+12,2} = i;
        discovered{i+12,3} = 0;

    end

    for i = 1:24
        if isequal(root(1:2),discovered(i,1:2))
            discovered{i,3} = 1;
        end
    end
    %
    Q = [root]; % colors, index, discovered
    while ~isempty(Q)
        v = Q(1,:);
        Q(1,:) = [];

        if isequal(v(1:2), goal)
            output = v;
        else
            moves = getSideMoves(v{2});
            cube_prev = v{3};
            for i = 1:length(moves)
                if ~isequal(moves{i}(1),'U')
                    cube_tmp = doAlgorithm(cube_prev,moves(i));
                    [~, sides_tmp] = getLocations(cube_tmp);
                    index_tmp = getRowLoc(color_goal,sides_tmp);
                    color_tmp = sides_tmp(index_tmp,:);
                    prevmoves = [v{4}, moves(i)];

                    node = {color_tmp,index_tmp,cube_tmp,prevmoves };

                    for k = 1:24
                        if isequal(node(1:2),discovered(k,1:2))
                            if discovered{k,3} == 0
                                discovered{k,3} = 1;
                                Q = [Q; node];

                            end
                        end
                    end
                end

            end
        end
    end

    cube_out = output{3};

    if isempty(output{4})
        algo_out = [];
    else
        algo_out = join(output{4});
    end

    plotcube(cube_out)


end

function cube = X(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    for i = 1:5
        cube(:,i,:) = rot90(squeeze(cube(:,i,:)),rot);
    end
end

function cube = Y(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    for i = 1:5
        cube(:,:,i) = rot90(squeeze(cube(:,:,i)),rot);
    end
end

function cube = Z(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    for i = 1:5
        cube(i,:,:) = rot90(squeeze(cube(i,:,:)),rot);
    end
end

function cube = M(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(:,3,:) = rot90(squeeze(cube(:,3,:)),rot);
end

function cube = E(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(:,:,3) = rot90(squeeze(cube(:,:,3)),rot);
end

function cube = S(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(3,:,:) = rot90(squeeze(cube(3,:,:)),rot);
 
end

function cube = L(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(:,1,:) = rot90(squeeze(cube(:,1,:)),rot);
    cube(:,2,:) = rot90(squeeze(cube(:,2,:)),rot);
end

function cube = R(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    cube(:,4,:) = rot90(squeeze(cube(:,4,:)),rot);
    cube(:,5,:) = rot90(squeeze(cube(:,5,:)),rot);
end

function cube = U(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    cube(:,:,1) = rot90(squeeze(cube(:,:,1)),rot);
    cube(:,:,2) = rot90(squeeze(cube(:,:,2)),rot);
end

function cube = D(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(:,:,4) = rot90(squeeze(cube(:,:,4)),rot);
    cube(:,:,5) = rot90(squeeze(cube(:,:,5)),rot);
end

function cube = F(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(4,:,:) = rot90(squeeze(cube(4,:,:)),rot);
    cube(5,:,:) = rot90(squeeze(cube(5,:,:)),rot);
end


function cube = B(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    cube(1,:,:) = rot90(squeeze(cube(1,:,:)),rot);
    cube(2,:,:) = rot90(squeeze(cube(2,:,:)),rot);
end



function [cube,algo] = shuffle(cube,seed)
    if nargin == 2
        rng(seed)
    end
    
    lenmoves = 30;
    moves = randi([1,18],lenmoves,1);
    algo = [];
    for i = 1:lenmoves
        switch moves(i) 
            case 1
                str = "F ";
            case 2
                str = "F' ";
            case 3
                str = "B ";
            case 4
                str = "B' ";
            case 5
                str = "L ";
            case 6
                str = "L' ";
            case 7
                str = "R ";
            case 8
                str = "R' ";
            case 9
                str = "U ";
            case 10
                str = "U' ";
            case 11
                str = "D ";
            case 12
                str = "D' ";
            case 13
                str = "F2 ";
            case 14
                str = "B2 ";
            case 15
                str = "L2 ";
            case 16
                str = "R2 ";
            case 17
                str = "U2 ";
            case 18
                str = "D2 ";  
        end
        
        algo = strcat(algo, str);
            
    end
    algo{1}(end) = [];
    cube = doAlgorithm(cube,algo);
end

%% plotting



function color = num2color(num)
    switch num
        case 1
            color = [0.9,0.9,0.9]; % white/gray
        case 2
            color = [1,1,0]; % yellow
        case 3
            color = [1,0,0]; % red
        case 4
            color = [1,0.6,0]; % orange
        case 5
            color = [0,0,1]; % blue
        case 6
            color = [0,1,0]; % green
    end    

end

function plotcube(cube)
clf

[r,c,v] = ind2sub(size(cube),find(cube ~= 0));
s1 = [0,1,1,0];
s2 = [0,0,1,1];
s3 = [0,0,0,0]; 


for i = 1:54
    x = r(i);
    y = c(i);
    z = v(i);
    
    if x == 1 || x == 5
        patch(s3+(-0.75*x+3.75) , s1+4-y , s2+4-z ,num2color(cube(x,y,z)));
    elseif y == 1 || y == 5
        patch(s1+4-x , s3+(-0.75*y+3.75) , s2+4-z ,num2color(cube(x,y,z)));
    elseif z == 1 || z == 5  
        patch(s1+4-x , s2+4-y , s3+(-0.75*z+3.75) ,num2color(cube(x,y,z)));
    end
end
% axis([-1,4,-1,4,-1,4])
view(-70,20)

end
%% get information 

function moves = getSideMoves(index)
    switch index
        case 1
            moves = ["B", "B'", "L", "L'"];
        case 2
            moves = ["F", "F'", "L", "L'"];
        case 3
            moves = ["B", "B'", "R", "R'"];
        case 4
            moves = ["F", "F'", "R", "R'"];
        case 5
            moves = ["B", "B'", "U", "U'"];
        case 6
            moves = ["F", "F'", "U", "U'"];
        case 7
            moves = ["B", "B'", "D", "D'"];
        case 8
            moves = ["F", "F'", "D", "D'"];
        case 9
            moves = ["L", "L'", "U", "U'"];
        case 10
            moves = ["R", "R'", "U", "U'"];
        case 11
            moves = ["L", "L'", "D", "D'"];
        case 12
            moves = ["R", "R'", "D", "D'"];  
    end 
end


function cube = newCube()
    cube = zeros(5,5,5);

    cube(2:4,2:4,1) = 1;
    cube(2:4,2:4,5) = 2;

    cube(1,2:4,2:4) = 3;
    cube(5,2:4,2:4) = 4;

    cube(2:4,1,2:4) = 5;
    cube(2:4,5,2:4) = 6;
end
function [corners, sides] = getLocations(cube)
corners = zeros(8,3);
sides = zeros(12,2);

bi8table = de2bi(0:7);
ranges = cell(3,1);
for i = 1:8
    for j = 1:3
        if bi8table(i,j) == 0
            ranges{j} = 1:2;
        else
            ranges{j} = 4:5;
        end
    end
    corners(i,:) = nonzeros(cube(ranges{1},ranges{2},ranges{3}))';
end

bi4table = de2bi(0:3);
ranges = cell(2,1);
for i = 1:4
    for j = 1:2
        if bi8table(i,j) == 0
            ranges{j} = 1:2;
        else
            ranges{j} = 4:5;
        end
    end
    sides(i,:) = nonzeros(cube(ranges{1},ranges{2}, 3 ))';
    sides(i+4,:) = nonzeros(cube(ranges{1},3, ranges{2}))';
    sides(i+8,:) = nonzeros(cube(3, ranges{1},ranges{2}))';
end


end


function index = getRowLoc(input,matrix)
    found = 0;
    index = 0;
    while found == 0 && index < size(matrix,1)
        index = index + 1;
        tmp = matrix(index,:);
        s = 0;
        for j = 1:length(input)
            s = s + sum(tmp == input(j));
        end
        if s == length(input)
            found = 1;
        end
    end

end



%% algorithms
function cube = doAlgorithm(cube,algo,pausetime)
if nargin == 2
    pausetime = 0;
end

algo = convertStringsToChars(algo);
moves = split(algo,' ');
for i = 1:length(moves)
    lenmove = length(moves{i});
    movefunc = str2func(moves{i}(1));
    
    prime = 0; 
    double = 0;
    
    if lenmove == 2
        if moves{i}(2) == "'" 
            prime = 1;
        end
        if moves{i}(2) == '2'
            double = 1;
        end 
    end
    if double == 1
        cube = movefunc(cube);
        cube = movefunc(cube);
    elseif prime == 1
        cube = movefunc(cube,prime);
    else
        cube = movefunc(cube);
    end
    
    
    if pausetime > 0
        plotcube(cube);
        pause(pausetime)
        
    end
end
end

function output = invAlgo(input)

algo = convertStringsToChars(input);
moves = split(algo,' ');
movesout = moves;
for i = 1:length(moves)
    if length(moves{i}) == 2
        if moves{i}(2) == "'"
            movesout{i}(2) = [];
        end
    else
        movesout{i}(2) = "'";
    end
end

movesout = flip(movesout);

output = strjoin(movesout,' ');

end

