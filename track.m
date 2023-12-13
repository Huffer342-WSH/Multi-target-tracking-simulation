close all; clear;
%%  参数设置
num_target = 4; % 假设创建 10 个结构体
time = 120; % 总时间
dt = 1; %时间步进
timestampNum = round(time / dt);
eps = 3; % DBSCAN 中的邻域距离阈值
MinPts = 2; % DBSCAN 中的最小点数阈值
radar1 = struct('position', [100, 150, 0], 'direction', [0, -1, 0]);
radar2 = struct('position', [0, -100, 0], 'direction', [0, 1, 0]);
fov = 100;

%% 生成预设目标信息（时间坐标，速度，面积，序号）
targetStruct = struct('timestamp', 0, 'position', [0, 0, 0], 'velocity', [0, 0, 0], 'area', 0, 'index', 0, 'cluster', 0, 'track', 0);

% 初始化结构体二维数组
PresetTargetsInfo = cell(timestampNum, 1);

for i = 1:timestampNum
  PresetTargetsInfo{i} = repmat(targetStruct, 4, 1); % 每个cell初始化为4x1的结构体数组
end

PresetTargetsInfo{1}(1) = struct('timestamp', 0, 'position', [-10, 20, 0], 'velocity', [1, 0, 0], 'area', 1, 'index', 1, 'cluster', 0, 'track', 0);
PresetTargetsInfo{1}(2) = struct('timestamp', 0, 'position', [0, 40, 0], 'velocity', [0, 1, 0], 'area', 0.5, 'index', 2, 'cluster', 0, 'track', 0);
PresetTargetsInfo{1}(3) = struct('timestamp', 0, 'position', [50, 60, 0], 'velocity', [5, 10, 0], 'area', 2, 'index', 3, 'cluster', 0, 'track', 0);
PresetTargetsInfo{1}(4) = struct('timestamp', 0, 'position', [10, 50, 0], 'velocity', [2, 0, 0], 'area', 0.5, 'index', 4, 'cluster', 0, 'track', 0);
t = 0;

for i = 2:timestampNum
  t = t + dt;
  PresetTargetsInfo{i}(1).timestamp = t;
  PresetTargetsInfo{i}(2).timestamp = t;
  PresetTargetsInfo{i}(3).timestamp = t;
  PresetTargetsInfo{i}(4).timestamp = t;
  % 直线
  PresetTargetsInfo{i}(1) = PresetTargetsInfo{i - 1}(1);
  PresetTargetsInfo{i}(1).position = PresetTargetsInfo{i}(1).position + dt * PresetTargetsInfo{i}(1).velocity;
  % 转弯
  turnRate = 0.0008; % 转弯率
  PresetTargetsInfo{i}(2) = PresetTargetsInfo{i - 1}(2);
  PresetTargetsInfo{i}(2).position = PresetTargetsInfo{i}(2).position + dt * PresetTargetsInfo{i}(2).velocity;
  PresetTargetsInfo{i}(2).velocity = PresetTargetsInfo{i}(2).velocity * [cos(turnRate * t), - sin(turnRate * t), 0; sin(turnRate * t), cos(turnRate * t), 0; 0, 0, 0];
  % 八字形
  PresetTargetsInfo{i}(3) = PresetTargetsInfo{i - 1}(3);
  PresetTargetsInfo{i}(3).position = PresetTargetsInfo{i}(3).position + dt * PresetTargetsInfo{i}(3).velocity;
  PresetTargetsInfo{i}(3).velocity = PresetTargetsInfo{i}(3).velocity +dt * PresetTargetsInfo{1}(3).velocity .* [0.1, 0.2, 0] .* [- sin(0.1 * t), - sin(0.2 * t), 0];

  % 操场
  x = rem(t, 100);
  theta = pi * (x - 25) / 25; % 角度从0到π
  PresetTargetsInfo{i}(4) = PresetTargetsInfo{i - 1}(4);
  PresetTargetsInfo{i}(4).position = PresetTargetsInfo{i}(4).position + dt * PresetTargetsInfo{i}(4).velocity;

  if x <= 25
    PresetTargetsInfo{i}(4).velocity = PresetTargetsInfo{1}(4).velocity;
  elseif x <= 50
    % 右侧半圆运动
    theta = pi * (x - 25) / 25; % 角度从0到π
    PresetTargetsInfo{i}(4).velocity = PresetTargetsInfo{1}(4).velocity(1) * [cos(theta), sin(theta), 0];
  elseif x <= 75
    PresetTargetsInfo{i}(4).velocity = [-1, 0, 0] .* PresetTargetsInfo{1}(4).velocity;
  elseif x <= 100
    % 左侧半圆运动
    PresetTargetsInfo{i}(4).velocity = PresetTargetsInfo{1}(4).velocity(1) * [-cos(theta), -sin(theta), 0];
  end

end

%% 绘制预设目标轨迹
if (true)
  figure('Name', '预设目标轨迹');
  hold on;

  for i = 1:4
    plot(cellfun(@(x) x(i).position(1), PresetTargetsInfo), cellfun(@(x) x(i).position(2), PresetTargetsInfo), 'DisplayName', sprintf('Target %d', i));
  end

  hold off;
  xlabel('X Position');
  ylabel('Y Position');
  title('预设目标轨迹');
  legend('Target 1 - 直线', 'Target 2 - 转弯', 'Target 3 - 8字形', 'Target 4 - 操场');

  %drawPoints(PresetTargetsInfo, true, 'presetTarget');
end

%% 对每个雷达分别生成点云
% radar1 点云
redarTargets1 = transformCoordinates(PresetTargetsInfo, radar1);
pointCloud1 = creatCloud(redarTargets1, fov);

% radar2 点云
redarTargets2 = transformCoordinates(PresetTargetsInfo, radar2);
pointCloud2 = creatCloud(redarTargets2, fov);

%% 雷达点云绘图（保存视频）

%drawPoints(pointCloud1, true, 'pointCloud1');%不带雷达边界
%drawPoints_withFOV(pointCloud1, fov, true, 'pointCloud1'); %带雷达边界
%drawPoints_withFOV(pointsCloud2, fov, true, 'pointCloud2');

%% 根据雷达坐标，预设目标信息，分别计算每个雷达下，点云的极坐标信息

%==================== 仿真的雷达数据 生成完毕 ===================================

%% 对每个雷达分别 聚类

[pointCloud1, cluster1] = clusterPointCloud(pointCloud1, eps, MinPts);
[pointCloud2, cluster2] = clusterPointCloud(pointCloud2, eps, MinPts);

%% 绘图

drawPoints_withFOV_Color(pointCloud1, fov, false, 'cluster');
drawPoints_withFOV_Color(pointCloud2, fov, false, 'cluster');

%% 融合

%clusterInfo1 clusterInfo2s
%同一个时刻中，速度距离相似，加权融合成一个
%clusterInfo

%% 关联

%卡尔曼滤波 包含 预测、纠正
%最近邻，根据当前坐标与速度预测下一个时刻的坐标，找到与预测值最接近的点，关联

% clusterInfo1 = 》 计算每一个目标的track clusterInfo{i}{j}.track

%% 将跟踪得到的路径和预设目标比较，评价
