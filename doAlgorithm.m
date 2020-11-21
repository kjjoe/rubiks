% function doAlgorithm
%
% Based on the input algorithm string, it performs the algorithm step by
% step on the cube. It outputs the cube after the algorithm is complete.
%
% input:  
%    - cube:      the starting 5x5 array cube
%    - algo:      an algorithm of type string
%    - pausetime: (optional) plot each step of the algorithm, pausing
%                 pausetime between each step
%
% output: 
%    - cube:      the ending 5x5 array cube
%
% See also: plotcube.m, and all movement functions


function cube = doAlgorithm(cube,algo,pausetime)
if nargin == 2
    pausetime = 0;
end

algo = convertStringsToChars(algo);
moves = split(algo,' ');
for i = 1:length(moves)
    lenmove = length(moves{i});
    movefunc = str2func(moves{i}(1));
    
    prime = 0; 
    double = 0;
    
    if lenmove == 2
        if moves{i}(2) == "'" 
            prime = 1;
        end
        if moves{i}(2) == '2'
            double = 1;
        end 
    end
    if double == 1
        cube = movefunc(cube);
        cube = movefunc(cube);
    elseif prime == 1
        cube = movefunc(cube,prime);
    else
        cube = movefunc(cube);
    end
    
    
    if pausetime > 0
        plotcube(cube);
        pause(pausetime)
        
    end
end
end
