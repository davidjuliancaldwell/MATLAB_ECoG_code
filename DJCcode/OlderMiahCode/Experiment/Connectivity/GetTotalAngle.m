function totalAngle = GetTotalAngle(jointAngles, calibRange, gloveGains, boneNum)

    colors = [
        [1 0 0];...
        [0 1 0];...
        [0 0 1];...
        [0 0 0];...
        [1 0 1];...
        [0 1 1];...
        [1 0.5 0];...
    ];

% colors = repmat([1 .8 .4],8,1);

    if nargin == 1
        load('C:\Research\Data\Patients\deca10\deca10_left.mat')
    end

    BoneTransforms = {
        %Thumb
        [
            -20 20 0 0;
            -41.3 4.1 -27 93.095;
            0 93.095 0 67.69
            0 67.69 0 49.92
        ],...
        {
            [1 1 .24 .97 0 -pi/8; 0 1 0 0 1 -pi/7; 4 1 0 0 1 -pi/2.5];
            [4 .8 1 0 0 0; 1 -1 1 0 0 0]; % 4
            [0 1 0 1 0 2*pi/5; 2 .8 1 0 0 0 ]; % 2
            [3 .8 1 0 0 -pi/8] % 3
        };
        % index
        [
            -39.669 162.81 0 83.973;
            0 83.973 0 47.368;
            0 47.368 0 33.058;
        ],...
        {
            [11 .45 0 0 -1 0; 5 1 1.2 0 0 0]; % ab, followed by flex
            [6 1 1 0 0 0];
            [7 1 1 0 0 0]
        };
        % middle
        [
            0 156.198 0 95.217;
            0 95.217 0 52.991;
            0 52.991 0 32.327;
        ],...
        {
            [8 1 1 0 0 0];
            [9 1 1 0 0 0];
            [10 1 1 0 0 0];
        };
        % ring
        [
            0 0 0 0; % base translation
            43.082 135.537 0 85.907;
            0 85.907 0 55.673;
            0 55.673 0 28.099;
        ],...
        {
            [20 .05 1 0 0 0 0];
            [15 .4 0 0 1 0; 12 1 1 0 0 0]; % ab, followed by flex
            [13 1 1 0 0 0];
            [14 1 1 0 0 0]
        }
        % pinkey
        [
            0 0 0 0; % base transform
            76.033 121.487 0 68.401;
            0 68.401 0 41.032;
            0 41.032 0 24.024;
        ],...
        {
            [20 .15 1 0 0 0 0];
            [19 1 0 0 1 0; 16 1 1 0 0 0]; % ab, followed by flex
            [17 1 1 0 0 0];
            [18 1 1 0 0 0]
        };
    };
%     patch(CreateLink([1 0 0 0; 0 1 0 0; 0 0 1 0; .75 -4 0 1], [1 4 1], [1 .6 0]));

    globalMat = eye(4);

    totalAngle = 0;
    
    for appendage = BoneTransforms(boneNum,:)'
        
        boneIdx = 1;
        rotations = appendage{2,:};
        for bone = appendage{1,:}'
            
            boneRot = rotations{boneIdx}';
            for rot = boneRot
                sensorIndex = rot(1);
                sensorContrib = rot(2);
                initialOffset = rot(6);
                
                if sensorIndex ~= 0
%                     minRange = min(calibRange(sensorIndex,:));
%                     maxRange = max(calibRange(sensorIndex,:));
                    minRange = calibRange(sensorIndex,1);
                    maxRange = calibRange(sensorIndex,2);
                    angle = (jointAngles(sensorIndex) - minRange) / (maxRange - minRange);
                    angle = angle * sensorContrib * gloveGains(sensorIndex) + initialOffset;
                else
                    angle = initialOffset;
                end
%                 transformMat(1:3,1:3) = vrrotvec2mat([rot(3:5)' angle]) * transformMat(1:3,1:3);
                totalAngle = totalAngle + angle;
            end
            boneIdx = boneIdx + 1;
        end
        
%         plot3(endPos(1),endPos(2),endPos(3),'color','r','markersize',40','marker','.');
    end
%     set(gca,'CameraPosition',[-18.5755   36.4840   38.6622]);
%     axis tight;
%     axis([-120 100 -25 330 -200 25 -1 1])
end

function outCube = CreateLink(transformMat, size, color)

    if ~exist('color','var')
        cube.facevertexcdata = [...
            [1 0 0 ];...
            [0 1 0 ];...
            [0 0 1 ];...
            [0 1 1 ];...
            [1 1 0 ];...
            [0 0 0 ];...
            [1 1 1 ];... 
            [1 0 1 ];...
        ];
    else 
        cube.facevertexcdata = repmat(color,8,1);
    end

    cube.vertices = [...
        [-1 -1 -1];...
        [ 1 -1 -1];...
        [ 1  1 -1];...
        [-1  1 -1];...
        [-1 -1  1];...
        [ 1 -1  1];...
        [ 1  1  1];...
        [-1  1  1];...
    ];

    % move the cube's origin to the front face
    cube.vertices = cube.vertices + repmat([0 1 0],8,1);
    
    % scale it so it's a unit in every direction
    cube.vertices = cube.vertices .* .5;
    
    % scale each axis
    cube.vertices = cube.vertices .* repmat(size,8,1);    
    
    % transform vertices
    verts = cube.vertices;
    verts(:,4) = 1;
    
    verts = verts * transformMat;
    
    cube.vertices = verts(:,1:3);
    


    cube.faces = [...
        [1 4 3];... % front
        [1 3 2];...
        [1 2 5];... % bottom
        [5 2 6];... 
        [2 6 3];...% right
        [3 6 7];...
        [3 4 8];...% top 
        [3 8 7];...
        [4 1 5];...% left 
        [4 5 8];...
        [8 6 5];...% back
        [8 7 6];...
    ];

    cube.facecolor = 'interp';
    cube.cdatamapping = 'scaled';

    outCube = cube;
end

function outPalm = CreatePalm(transformMat, size, color)

    palm.vertices = [...
        [-38.7    13.4 36];...
        [-48.7 159.68    36];...
        [1.653  156.12  36];...
        [43.8   135.5  36];...
        [74.79  117.794  36];...
        [41.0 -6.5    36];...
        
        [-38.7    13.4 -36];...
        [-48.7 159.68    -36];...
        [1.653  156.12  -36];...
        [43.8   135.5  -36];...
        [74.79  117.794  -36];...
        [41.0 -6.5    -36];...
    ];

    palm.vertices(:,3) = palm.vertices(:,3) .* 0.25;
    
    palm.faces = [...
        [1 2 3];...
        [1 3 4];...
        [1 4 5];...
        [1 5 6];...
        
        [7 12 11];...
        [7 11 10];...
        [7 10 9];...
        [7 9 8];...
        
        [7 1 2];... % 
        [7 2 8];...
        
        [8 2 3];... % 
        [8 3 9];...
        
        [9 3 4];... % 
        [9 4 10];...
        
        [10 4 5];... % 
        [10 5 11];...
        
        [11 5 6];... % 
        [11 6 12];...
        
        [12 6 1];... % 
        [12 1 7];...
    ];

    if ~exist('color','var')
        palm.facevertexcdata = [...
            [1 0 0 ];...
            [0 1 0 ];...
            [0 0 1 ];...
            [0 1 1 ];...
            [1 1 0 ];...
            [0 0 0 ];...
            [1 1 1 ];... 
            [1 0 1 ];...
            [1 1 0 ];...
            [0 0 0 ];...
            [1 1 1 ];... 
            [1 0 1 ];...
        ];
    else 
        palm.facevertexcdata = repmat(color,12,1);
    end
    
     % transform vertices
    verts = palm.vertices;
    verts(:,4) = 1;
    
    verts = verts * transformMat;
    
    palm.vertices = verts(:,1:3);
    
    palm.facecolor = 'interp';
    palm.cdatamapping = 'scaled';

    outPalm = palm;
end