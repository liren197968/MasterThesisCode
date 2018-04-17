function flag = predicate(region)
sd = std2(region);
m = mean2(region);
flag = (m > 0);
end