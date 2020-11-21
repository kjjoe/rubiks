% Move face or cube of function name in clockwise direction if that side
% was in front.
%
% input:  
%    - cube:      the starting 5x5 array cube
%    - prime:     (Optional) Move counter clockwise
%
% output: 
%    - cube:      the ending 5x5 array cube

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