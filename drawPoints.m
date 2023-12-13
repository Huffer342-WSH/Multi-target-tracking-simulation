function drawPoints(targetsInfo, generateVideo, videoFileName)

  positions = cell2mat(cellfun(@(x) cat(1, x.position), targetsInfo, 'UniformOutput', false));
  minX = min(positions(:, 1));
  maxX = max(positions(:, 1));
  minY = min(positions(:, 2));
  maxY = max(positions(:, 2));

  padding = 10;
  minX = minX - padding;
  maxX = maxX + padding;
  minY = minY - padding;
  maxY = maxY + padding;

  if generateVideo
    videoFile = VideoWriter(['./video/', videoFileName, '.mp4'], 'MPEG-4');
    open(videoFile);
  end

  figure('units', 'normalized', 'outerposition', [0 0 1 1]);

  for i = 1:numel(targetsInfo)
    clf;
    pos = cat(1, targetsInfo{i}.position);

    scatter(pos(:, 1), pos(:, 2), 'filled');
    title(['Frame ', num2str(i)]);
    xlabel('X');
    ylabel('Y');
    xlim([minX, maxX]);
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
