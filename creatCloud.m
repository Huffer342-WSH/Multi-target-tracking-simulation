function pointClouds = creatCloud(targets, fov)
  slope = atan((180 - fov) / 360 * pi);
  timestampNum = numel(targets);
  pointClouds = cell(timestampNum, 1);

  for i = 1:timestampNum
    pointClouds{i} = [];

    for j = 1:length(targets{i})
      tempTarget = targets{i}(j);
      tempNum = randi(floor([5, 8] * tempTarget.area), 1, 1);

      for k = 1:tempNum
        tempPoint = targets{i}(j);
        tempPoint.position = tempPoint.position + randn(1, 3) * tempTarget.area;

        if tempPoint.position(2) > abs(tempPoint.position(1)) * slope
          pointClouds{i} = [pointClouds{i}; tempPoint];
        end

      end

    end

  end

end
