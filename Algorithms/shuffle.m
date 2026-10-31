% function shuffle
%
% Shuffle cube for 30 random quarter/half moves.
%
% input:  
%    - cube:  the starting 5x5 array cube
%    - seed:  (Optional) set seed for rng
%
% output: 
%    - cube:  the ending 5x5 array cube
%    - algo:  the algorithm of type string that shuffled starting cube
%
% See also: doAlgorithm.m, invAlgo.m


function [cube,algo] = shuffle(cube,seed,nummoves,doublesFlag)
    algo = [];

    if nummoves > 0 
        if nargin < 4
            doublesFlag = 1;
        end
        if nargin < 3
            nummoves = 30;
        end

        if ~isempty(seed)
            rng(seed);
        end


        if doublesFlag
            moves = randi([1,18],nummoves,1);
        else
            moves = randi([1,12],nummoves,1);
        end
        
        for i = 1:nummoves
            switch moves(i) 
                case 1
                    str = "F ";
                case 2
                    str = "F' ";
                case 3
                    str = "B ";
                case 4
                    str = "B' ";
                case 5
                    str = "L ";
                case 6
                    str = "L' ";
                case 7
                    str = "R ";
                case 8
                    str = "R' ";
                case 9
                    str = "U ";
                case 10
                    str = "U' ";
                case 11
                    str = "D ";
                case 12
                    str = "D' ";
                case 13
                    str = "F2 ";
                case 14
                    str = "B2 ";
                case 15
                    str = "L2 ";
                case 16
                    str = "R2 ";
                case 17
                    str = "U2 ";
                case 18
                    str = "D2 ";  
            end

            algo = strcat(algo, str);

        end

        algo{1}(end) = [];
        cube = doAlgorithm(cube,algo);
    end
end