function [labels, numClusters] = dbscanWithVelocity3D(coordinates, velocities, epsilon, minPts, velocityThreshold)
    labels = ones(size(coordinates, 1), 1) * -1;
    clusterID = 0;
    
    for i = 1:size(coordinates, 1)
        if labels(i) ~= -1
            continue;
        end
        
        neighbors = find_neighbors(coordinates, i, epsilon, velocities, velocityThreshold);
        
        if length(neighbors) < minPts
            labels(i) = 0;
            continue;
        end
        
        clusterID = clusterID + 1;
        labels(i) = clusterID;
        
        for j = 1:length(neighbors)
            neighborIdx = neighbors(j);
            if labels(neighborIdx) == 0
                labels(neighborIdx) = clusterID;
            elseif labels(neighborIdx) == -1
                labels(neighborIdx) = clusterID;
            end
        end
    end
    
    numClusters = clusterID;
end

function neighbors = find_neighbors(coordinates, idx, epsilon, velocities, velocityThreshold)
    neighbors = [];
    for i = 1:size(coordinates, 1)
        distance = sqrt(sum((coordinates(idx, :) - coordinates(i, :)).^2));
        velocityDiff = abs(velocities(idx) - velocities(i));
        
        if distance <= epsilon && velocityDiff <= velocityThreshold
            neighbors = [neighbors, i];
        end
    end
end
