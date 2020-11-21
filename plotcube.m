% function plotcube
%
% plot current state of the cube. It does not plot all the inner faces and
% should not be used for animation. Mainly used for debugging.
%
% input:  
%    - cube: 5x5 representation of the cube
%
% output: 
%
% See also: shuffle.m, doAlgorithm.m


function plotcube(cube)
clf

[r,c,v] = ind2sub(size(cube),find(cube ~= 0));
s1 = [0,1,1,0];
s2 = [0,0,1,1];
s3 = [0,0,0,0]; 


for i = 1:54
    x = r(i);
    y = c(i);
    z = v(i);
    
    if x == 1 || x == 5
        patch(s3+(-0.75*x+3.75) , s1+4-y , s2+4-z ,num2color(cube(x,y,z)));
    elseif y == 1 || y == 5
        patch(s1+4-x , s3+(-0.75*y+3.75) , s2+4-z ,num2color(cube(x,y,z)));
    elseif z == 1 || z == 5  
        patch(s1+4-x , s2+4-y , s3+(-0.75*z+3.75) ,num2color(cube(x,y,z)));
    end
end
% axis([-1,4,-1,4,-1,4])
view(-70,20)

end