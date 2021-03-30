function n = spacial_averaging (listOfAlines)
listOfAlines_copy = movmean(listOfAlines,[5 5]);
k = length(listOfAlines);
listOfAlines_copy(1) = (listOfAlines(1) + listOfAlines(2) + listOfAlines(3) + listOfAlines(4) + listOfAlines(5) + listOfAlines(6)+ listOfAlines(k) + listOfAlines(k - 1) + listOfAlines(k - 2) + listOfAlines(k - 3)+ listOfAlines(k - 4))/11;
listOfAlines_copy(2) = (listOfAlines(2) + listOfAlines(3) + listOfAlines(4) + listOfAlines(5) + listOfAlines(6) + listOfAlines(7) + listOfAlines(1) + listOfAlines(k) + listOfAlines(k - 1)+ listOfAlines(k - 2) + listOfAlines(k - 3))/11;
listOfAlines_copy(3) = (listOfAlines(3) + listOfAlines(4) + listOfAlines(5) + listOfAlines(6) + listOfAlines(7) + listOfAlines(8) + listOfAlines(2) + listOfAlines(1) + listOfAlines(k)+ listOfAlines(k - 1) + listOfAlines(k - 2))/11;
listOfAlines_copy(4) = (listOfAlines(4) + listOfAlines(5) + listOfAlines(6) + listOfAlines(7) + listOfAlines(8) + listOfAlines(9) + listOfAlines(1) + listOfAlines(2) + listOfAlines(3)+ listOfAlines(k) + listOfAlines(k-1))/11;
listOfAlines_copy(5) = (listOfAlines(5) + listOfAlines(6) + listOfAlines(7) + listOfAlines(8) + listOfAlines(9) + listOfAlines(10) + listOfAlines(1) + listOfAlines(2) + listOfAlines(3)+ listOfAlines(4) + listOfAlines(k))/11;
listOfAlines_copy(k) = (listOfAlines(k) + listOfAlines(1) + listOfAlines(2) + listOfAlines(3) + listOfAlines(4) + listOfAlines(5) + listOfAlines(k-1) + listOfAlines(k-2) + listOfAlines(k - 3)+ listOfAlines(k - 4) + listOfAlines(k - 5))/11;
listOfAlines_copy(k - 1) = (listOfAlines(k-1) + listOfAlines(k) + listOfAlines(1) + listOfAlines(2) + listOfAlines(3) + listOfAlines(4) + listOfAlines(k-2) + listOfAlines(k-3) + listOfAlines(k - 4)+ listOfAlines(k - 5) + listOfAlines(k - 6))/11;
listOfAlines_copy(k - 2) = (listOfAlines(k-2) + listOfAlines(k-1) + listOfAlines(k) + listOfAlines(1) + listOfAlines(2) + listOfAlines(3) + listOfAlines(k-3) + listOfAlines(k-4) + listOfAlines(k - 5)+ listOfAlines(k - 6) + listOfAlines(k - 7))/11;
listOfAlines_copy(k - 3) = (listOfAlines(k-3) + listOfAlines(k-2) + listOfAlines(k-1) + listOfAlines(k) + listOfAlines(1) + listOfAlines(2) + listOfAlines(k-4) + listOfAlines(k-5) + listOfAlines(k - 6)+ listOfAlines(k - 7) + listOfAlines(k - 8))/11;
listOfAlines_copy(k - 4) = (listOfAlines(k-4) + listOfAlines(k-3) + listOfAlines(k-2) + listOfAlines(k-1) + listOfAlines(k) + listOfAlines(1) + listOfAlines(k-5) + listOfAlines(k-6) + listOfAlines(k - 7)+ listOfAlines(k - 8) + listOfAlines(k - 9))/11;

n=listOfAlines_copy;
end 


