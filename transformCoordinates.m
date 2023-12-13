function relativeInfo = transformCoordinates(PresetTargetsInfo, radar)
  radarDirection = radar.direction; % Radar's direction vector

  % Assuming radar points along Y-axis [0, 1, 0]
  yAxis = [0, 1, 0];

  % Calculate the rotation axis and angle
  if (norm(yAxis) * norm(radarDirection)) == 0
    rotationAngle = 0;
  else
    rotationAngle = acosd(dot(yAxis, radarDirection) / (norm(yAxis) * norm(radarDirection)));
  end

  relativeInfo = cell(size(PresetTargetsInfo));

  for i = 1:numel(PresetTargetsInfo)
    targets = PresetTargetsInfo{i};
    relativeTargets = struct('timestamp', {}, 'position', {}, 'velocity', {}, 'area', [], 'index', [], 'cluster', [], 'track', []);

    for j = 1:numel(targets)
      targetPos = targets(j).position;
      targetVel = targets(j).velocity;

      % Calculate relative position
      relativePos = targetPos - radar.position;

      % Convert position to radar coordinates
      % Rotate the position vector to align with radar direction
      relativePosRotated = transformCoordinatesZAxis(relativePos, rotationAngle);
      relativeVelRotated = transformCoordinatesZAxis(targetVel, rotationAngle);

      % Store relative information in the structure
      relativeTargets(j).timestamp = targets(j).timestamp;
      relativeTargets(j).position = relativePosRotated;
      relativeTargets(j).velocity = relativeVelRotated; % Velocity remains unchanged
      relativeTargets(j).area = targets(j).area;
      relativeTargets(j).index = targets(j).index;
      relativeTargets(j).cluster = targets(j).cluster;
      relativeTargets(j).track = targets(j).track;
    end

    relativeInfo{i} = relativeTargets;
  end

end

function new_coords = transformCoordinatesZAxis(old_coords, angle)
  % 将角度转换为弧度
  theta = deg2rad(angle);

  % 定义绕Z轴旋转的旋转矩阵
  rotation_matrix = [cos(theta), -sin(theta), 0;
                     sin(theta), cos(theta), 0;
                     0, 0, 1];

  % 对坐标进行变换
  new_coords = (rotation_matrix * old_coords')';
end
