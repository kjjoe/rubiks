% Move face or cube of function name in clockwise direction if that side
% was in front.
%
% input:  
%    - cube:      the starting 5x5 array cube
%    - prime:     (Optional) Move counter clockwise
%
% output: 
%    - cube:      the ending 5x5 array cube

function cube = U(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    cube(:,:,1) = rot90(squeeze(cube(:,:,1)),rot);
    cube(:,:,2) = rot90(squeeze(cube(:,:,2)),rot);
end