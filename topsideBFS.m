% function topsideBFS
%
% Use Breadth-First Search (BFS) to find the fastest algorithm that moves
% the last 3 side pieces to their desired locations. This is the very last
% method used  and moves 3 side pieces with harming anything else. It
% assumes that 1 of the side pieces in the top layer is already solved.
%
% input:
%    - cube:       5x5 representation of the cube
%    - sidesSolve: matrix representing location of the sides based on color
%                  and location of a solved. "The desired locations"
%
% output: 
%    - cube:  the ending 5x5 array cube
%    - algo:  the algorithm of type string that shuffled starting cube
%
% See also: getRowLoc.m, doAlgorithm.m


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
