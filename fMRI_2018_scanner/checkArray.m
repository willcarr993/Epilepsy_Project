function good = checkArray(array)
good = 1;
for i=2:length(array)
    if array(i,1)== array(i-1,1)
        good = 0;
    end
end