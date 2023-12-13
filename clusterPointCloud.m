function [pointCloud, cluster] = clusterPointCloud(pointCloud, eps, MinPts)
    cluster = cell(length(pointCloud), 1);

    for i = 1:numel(pointCloud)
        pos = cat(1, pointCloud{i}.position);
        vel = cat(1, pointCloud{i}.velocity);

        % 使用 DBSCAN 聚类算法对当前 cell 中的数据进行聚类
        IDX = dbscan([pos, vel], eps, MinPts);
        numClusters = max(IDX);

        % 为每个点设置聚类标签
        for j = 1:numel(pointCloud{i})
            pointCloud{i}(j).cluster = IDX(j);
        end

        % 为每个聚类计算中心点和半径
        for j = 1:numClusters
            temp = pointCloud{i}([pointCloud{i}.cluster] == j);
            clusterPos = cat(1, temp.position);

            % 计算中心点
            center = mean(clusterPos);

            % 计算每个点到中心点的距离
            distances = sqrt(sum((clusterPos - center) .^ 2, 2));

            % 使用距离的标准差作为半径估计
            radius = std(distances);
            
            % 保存聚类信息
            cluster{i}(j).position = center;
            cluster{i}(j).velocity = mean(cat(1, temp.velocity));
            cluster{i}(j).cluster = j;
            cluster{i}(j).area = radius * radius;
        end
    end
end
