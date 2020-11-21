% All movement functions. 


function cube = X(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    for i = 1:5
        cube(:,i,:) = rot90(squeeze(cube(:,i,:)),rot);
    end
end

function cube = Y(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    for i = 1:5
        cube(:,:,i) = rot90(squeeze(cube(:,:,i)),rot);
    end
end

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

function cube = M(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(:,3,:) = rot90(squeeze(cube(:,3,:)),rot);
end

function cube = E(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(:,:,3) = rot90(squeeze(cube(:,:,3)),rot);
end

function cube = S(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(3,:,:) = rot90(squeeze(cube(3,:,:)),rot);
 
end

function cube = L(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(:,1,:) = rot90(squeeze(cube(:,1,:)),rot);
    cube(:,2,:) = rot90(squeeze(cube(:,2,:)),rot);
end

function cube = R(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    cube(:,4,:) = rot90(squeeze(cube(:,4,:)),rot);
    cube(:,5,:) = rot90(squeeze(cube(:,5,:)),rot);
end

function cube = U(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    cube(:,:,1) = rot90(squeeze(cube(:,:,1)),rot);
    cube(:,:,2) = rot90(squeeze(cube(:,:,2)),rot);
end

function cube = D(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(:,:,4) = rot90(squeeze(cube(:,:,4)),rot);
    cube(:,:,5) = rot90(squeeze(cube(:,:,5)),rot);
end

function cube = F(cube,prime)
    if nargin == 1
        rot = 1;
    else
        rot = 3;
    end
        
    cube(4,:,:) = rot90(squeeze(cube(4,:,:)),rot);
    cube(5,:,:) = rot90(squeeze(cube(5,:,:)),rot);
end


function cube = B(cube,prime)
    if nargin == 1
        rot = 3;
    else
        rot = 1;
    end
        
    cube(1,:,:) = rot90(squeeze(cube(1,:,:)),rot);
    cube(2,:,:) = rot90(squeeze(cube(2,:,:)),rot);
end