% function newCube
%
% Output a freshly solved cube.
%
% input:  
%
% output: 
%    - cube: 5x5 representation of the cube that is clean.
%
% See also: shuffle.m, doAlgorithm.m

function cube = newCube()
    cube = zeros(5,5,5);

    cube(2:4,2:4,1) = 1;
    cube(2:4,2:4,5) = 2;

    cube(1,2:4,2:4) = 3;
    cube(5,2:4,2:4) = 4;

    cube(2:4,1,2:4) = 5;
    cube(2:4,5,2:4) = 6;
end