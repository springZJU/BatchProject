function [resVal,idx] = findWithinInterval(value,range)
    idx = find(value>range(1) & value<range(2));
    resVal = value(idx);
end