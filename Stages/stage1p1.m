% function stage1p1
%
% First stage part 1 of solving the cube. Solve the cross on the top layer of the
% cube.
%
% input:  
%    - cube:       current state of the cube
%    - cubeSolved: desired cube given orientation
%    - plotLogic:  plot the cube or not
%
% output: 
%    - cube:       output state of the cube
%    - cubeSolved: output state of the solved cube. changes if rotated
%    - total_algo: algorithm in this stage
%
% See also: sideBFS.m, stage1p2.m



function [cube,cubeSolved,total_algo] = stage1p1(cube,cubeSolved,plotLogic)
rng(1)
[~, sidesSolve] = getLocations(cubeSolved);

cross = [5,6,9,10];
exitCross = 0;
steps = 0;
total_algo = [];

while exitCross == 0 && steps < 10
    checkCross = 0;
    cross = cross(randperm(length(cross)));
    for i = 1:4
        index_goal = cross(i);
        [cube, algo_out] = sideBFS(cube,index_goal,sidesSolve);
        if isempty(algo_out)
            checkCross = checkCross + 1;
        else
            total_algo = [total_algo, algo_out];
        end
    end
    
    if checkCross == 4
        exitCross = 1;
    end
    steps = steps+1;
    if plotLogic == 1
	     plotcube(cube);
    end
end
total_algo = join(total_algo);

end
