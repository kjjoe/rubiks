% function animateSolution
%
% This function animates moves an algorithm on a shuffled cube with a given
% seed. It is possible to save 
% input:
%    - total_algo: algorithm to animate
%    - seed:       corresponding rng seed to shuffle the cube
%    - makevideo:  (optional, default = 0) Make a video (1) or not (0)
%    - namevideo:  (optional, default = 'rubiks(randint).avi' ) name of the
%                  video to save
%
% output: 
%


function animateSolution(total_algo, seed, makevideo, namevideo)
%% Properties

incstep = 0.05;
framerate = 60;


%% initialization
if nargin == 3
    namevideo = ['rubiks', num2str(randi([0,1000])),'.avi'];
elseif nargin == 2
    makevideo = 0;
    namevideo = ['rubiks', num2str(randi([0,1000])),'.avi'];
end

if makevideo == 1
    video = VideoWriter(namevideo);
    video.FrameRate = framerate;
    open(video)
end


%% Plot initial state of the cube and shuffle
cube = newCube();
[cube,~] = shuffle(cube,seed);
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

pause(0.00001)

if makevideo == 1
    frame = getframe(gcf);
    writeVideo(video,frame);
end

%% begin reading algorithm to solve, animate each move

algo = convertStringsToChars(total_algo);
moves = split(algo,' ');
for i = 1:length(moves)
    lenmove = length(moves{i});
    movefunc = str2func(moves{i}(1));
    
    % linear movement
%     incrange = incstep:incstep:0.5; % property
    
    % parabolic movement. looks cleaner
    incrange = [ (incstep:incstep:0.5).^2, 0.5 - (0.5:-incstep:incstep).^2] ;
    
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
        drawnow()
        
        
        pause(0.00001)
        if makevideo == 1
            frame = getframe(gcf);
            writeVideo(video,frame);
        end
    end
    
    [colors,faces] = getFaceColors(cube);
end

%% last frame
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

if makevideo == 1
    close(video);
end

end


% hard coded to read the faces of each possible "face" that is moveable
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

% gather the patch coordinates for one piece. Before, it used to plot each
% cube at a time, but now it gathers it all for one call of patch per
% frame. Significantly faster
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
