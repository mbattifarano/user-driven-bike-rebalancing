function [utils] = support()
%UTILS Summary of this function goes here
%   Detailed explanation goes here
utils = struct();
utils.computeIncentivizedFlow = @computeIncentivizedFlow;
utils.swapStationIndices = @swapStationIndices;
utils.toStationTimeIndex = @toStationTimeIndex;
utils.splitDstar = @splitDstar;
end

function [f] = computeIncentivizedFlow(p, alpha, dinc, dstar)
    f = (alpha * swapStationIndices(p, dstar) + swapStationIndices(p, dinc)) - ...
        (alpha * dstar + dinc);
    f = squeeze(sum(toStationTimeIndex(p, f), 2));
    f = f(:);
end

function [b] = swapStationIndices(p, d)
    b = permute(toStationTimeIndex(p, d), [2, 1, 3]);
    b = b(:);
end

function [matrix] = toStationTimeIndex(p, vector)
    if size(vector, 2) ~= 1
        error("toStationTimeIndex:badDimension",  "Input must be a column vector.");
    end
    switch numel(vector)
        case (p.N * p.T)
            matrix = reshape(vector, p.N, p.T);
        case (p.N * p.N * p.T)
            matrix = reshape(vector, p.N, p.N, p.T);
        case (p.N * p.N)
            matrix = reshape(vector, p.N, p.N);
        otherwise
            error("toStationTimeIndex:badNumel", "wrong number of elements");
    end
end

function [dstarO, dstarD] = splitDstar(p, dstar)
    dstarO = dstar(1:(p.N*p.N*p.T));
    dstarD = dstar((p.N*p.N*p.T+1):end);
end