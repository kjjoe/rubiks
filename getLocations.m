% function getLocations
%
% Based on the current state of the cube, output the current state of the
% corner colors and sides colors. Order based on the location on the cube
% always stays the same
%
% input:  
%    - cube:      the starting 5x5 array cube
%
% output: 
%    - corners:   A matrix of all corners with numbered color by location
%    - sides:     A matrix of all sides with numbered color by location
%
% See also: getLocations.m


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