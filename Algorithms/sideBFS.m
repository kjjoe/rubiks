% function sideBFS
%
% Use Breadth-First Search (BFS) to find the fastest algorithm that moves
% the desired piece to the correct location. Never move the U face so that
% it does not fall into a never ending loop. This method is used to solve
% the first cross.
%
% input:
%    - cube:       5x5 representation of the cube
%    - index_goal: index of side piece to solve
%    - sidesSolve: matrix representing location of the sides based on color
%                  and location of a solved. "The desired location"
%
% output: 
%    - cube:  the ending 5x5 array cube
%    - algo:  the algorithm of type string that shuffled starting cube
%
% See also: getRowLoc.m, doAlgorithm.m


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