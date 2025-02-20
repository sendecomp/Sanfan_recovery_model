function v = nchoosek2(n, k)
if k ==0
    v = ones(1, 0);
else
    v = nchoosek(n, k);
end