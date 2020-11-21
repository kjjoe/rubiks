% function checkTopCorner
%
% This function outputs the number of corners that are in the correct 
% location, regardless of the color orientation. Anywhere from 0 to 4.
% Ideally it is 4. Function used when solving the last layer. I made the
% function only because I had to call this at multiple locations.
%
% input:
%    - cube:         5x5 representation of the cube
%    - cornersSolve: matrix representing location of the corners based on color
%                    and location of a solved. "The desired location"
%
% output: 
%    - match: The number of corners that are in the correct location,
%             regardless of the color orientation. Anywhere from 0 to 4.
%


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