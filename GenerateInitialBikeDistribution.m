function s = GenerateInitialBikeDistribution(b,distribution)

if strcmp(distribution,'Uniform')
    s = round(rand(length(b),1).*b);
elseif strcmp(distribution,'Normal')
    normdist = normpdf(linspace(-3,3,100),0,1)';
    normdist = normdist/max(normdist);
    s = round(normdist(randi(100,length(b),1)).*b);
elseif strcmp(distribution,'Poisson')
    poissdist = poisspdf(0:99,33)';
    poissdist = poissdist/max(poissdist);
    s = round(poissdist(randi(100,length(b),1)).*b);
elseif strcmp(distribution,'Exponential')
    expdist = exppdf(linspace(0,10,100),2)';
    expdist = expdist/max(expdist);
    s = round(expdist(randi(100,length(b),1)).*b);
end

end