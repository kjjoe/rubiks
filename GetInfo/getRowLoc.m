% function getRowLoc
%
% Based on the current locations of the sides or corners, find the row
% location of the desired "color" within matrix.
%
% input:  
%    - color: vector (1x2) or (1x3), depending on side or corner
%    - matrix: all sides or corners based on ordered location
%
% output: 
%    - index: row index of the color in matrix
%
% See also: getLocations.m

function index = getRowLoc(color,matrix)
    found = 0;
    index = 0;
    while found == 0 && index < size(matrix,1)
        index = index + 1;
        tmp = matrix(index,:);
        s = 0;
        for j = 1:length(color)
            s = s + sum(tmp == color(j));
        end
        if s == length(color)
            found = 1;
        end
    end

end