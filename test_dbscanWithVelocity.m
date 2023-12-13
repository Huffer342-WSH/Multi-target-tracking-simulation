% 生成测试数据
rng(42); % 设置随机数种子以保证结果可重复
numPoints = 100;
data = rand(numPoints, 4); % 生成随机的位置和速度信息

% 设定 epsilon、minPts 和 maxVelocityDiff 参数
epsilon = 0.2;
minPts = 5;
maxVelocityDiff = 0.1;

% 运行带有速度因素的 DBSCAN
[clusterLabels, numClusters] = dbscanWithVelocity(data, epsilon, minPts, maxVelocityDiff);

% 显示聚类结果
disp("聚类标签:");
disp(clusterLabels);
disp("簇的数量:");
disp(numClusters);
