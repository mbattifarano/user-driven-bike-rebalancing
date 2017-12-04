%% Test generated parameters

p = generateTestParameters();
assert(sum(p.dO) == sum(p.s));
assert(sum(p.dD) == sum(p.s));
assert(sum(p.dOinc) == 3);
assert(sum(p.dDinc) == 4);