% function getSideMoves
%
% Based on the current location of the given side piece (index), output the
% possible moves that will change the location of the side piece
%
% input:  
%    - index: current location of the side piece
%
% output: 
%    - corners:   A matrix of all corners with numbered color by location
%
% See also: getLocations.m



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