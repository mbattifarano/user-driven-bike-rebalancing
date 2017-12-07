function dist = createdistancematrix (lat,long)
dist = squareform(pdist([lat,long]));