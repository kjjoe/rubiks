% function num2color
%
% This function decides the color of the sides of the cube.
%
% input:
%    - num: A number between 1:6 representing the colors for cube when
%           plotting / animation
%
% output: 
%    - color: The color based on given number
%
% See also: newCube.m, plotcube.m

function color = num2color(num)
    switch num
        case 1
            color = [0.9,0.9,0.9]; % white/gray
        case 2
            color = [1,1,0]; % yellow
        case 3
            color = [1,0,0]; % red
        case 4
            color = [1,0.6,0]; % orange
        case 5
            color = [0,0,1]; % blue
        case 6
            color = [0,1,0]; % green
    end    

end