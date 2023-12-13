function drawPoints_withFOV(targetsInfo, fov, generateVideo, videoFileName)

  slope = atan((180 - fov) / 360 * pi);

  positions = cell2mat(cellfun(@(x) cat(1, x.position), targetsInfo, 'UniformOutput', false));
  minX = min(positions(:, 1));
  maxX = max(positions(:, 1));
  minY = min(positions(:, 2));
  maxY = max(positions(:, 2));

  padding = 10;

  maxX = max(abs(maxX), abs(minX)) + padding;
  xRange = [-maxX, maxX];
  minY = minY - padding;
  maxY = maxY + padding;

  if minY > 0
    minY = 0;
  end

  if abs(minX) > abs(maxX)

  end

  if generateVideo
    videoFile = VideoWriter(['./video/', videoFileName, '.mp4'], 'MPEG-4');
    open(videoFile);
  end

  figure('units', 'normalized', 'outerposition', [0 0 1 1]);

  for i = 1:numel(targetsInfo)
    clf;
    pos = cat(1, targetsInfo{i}.position);

    scatter(pos(:, 1), pos(:, 2), 'filled');
    hold on;
    line([-maxX, 0], [maxX * slope, 0], 'Color', 'r', 'LineWidth', 2, 'LineStyle', '--');
    line([0, maxX], [0, maxX * slope], 'Color', 'r', 'LineWidth', 2, 'LineStyle', '--');

    hold off;
    title(['Frame ', num2str(i)]);
    xlabel('X');
    ylabel('Y');
    xlim(xRange);
    ylim([minY, maxY]);
    drawnow;

    if generateVideo
      frame = getframe(gcf);
      writeVideo(videoFile, frame);
    end

  end

  close;

  if generateVideo
    close(videoFile);
  end

end
