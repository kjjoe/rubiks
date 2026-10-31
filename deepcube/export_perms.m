% export_perms
%
% Export the MATLAB cube's move functions as sticker permutations for the
% Python DeepCube code. Each of the 54 sticker slots in the 5x5x5 cube gets a
% unique label, the move is applied, and where each label ends up gives the
% permutation. Run from the repo root.
%
% output: deepcube/data/cube_perms.json, deepcube/data/cube_testcase.json
%
% See also: newCube.m, doAlgorithm.m

addpath('Algorithms','GetInfo','Movement','Plot','Stages');
c0 = newCube();
idx = find(c0 ~= 0);              % 54 sticker slots, column-major order
lab = zeros(5,5,5); lab(idx) = 1:54;
faces = {'U','D','L','R','F','B'};
s = struct();
s.sticker_linear_index = idx' - 1;   % 0-based into 5x5x5 (column-major)
s.solved_colors = c0(idx)';
for k = 1:numel(faces)
    f = str2func(faces{k});
    a = f(lab);  b = f(lab,1);
    s.(faces{k}) = a(idx)' - 1;        % new_state = old_state[perm]
    s.([faces{k} '_prime']) = b(idx)' - 1;
    assert(isequal(f(f(f(f(lab)))), lab)); assert(isequal(f(f(lab),1), lab));
end
fid = fopen('deepcube/data/cube_perms.json','w');
fwrite(fid, jsonencode(s, 'PrettyPrint', true)); fclose(fid);

% one scramble done by doAlgorithm, used by the Python tests
[cs, algo] = shuffle(newCube(), 7, 25);
t.algo = char(algo); t.colors = cs(idx)';
fid = fopen('deepcube/data/cube_testcase.json','w');
fwrite(fid, jsonencode(t)); fclose(fid);
