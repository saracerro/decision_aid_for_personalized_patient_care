
%------------------ HOLDOUT CREATION FUNCTION --------------------
function HO = createHoldOutIndex(labels, testRatio)
n = length(labels);
cv = cvpartition(labels, 'HoldOut', testRatio);
HO.training = training(cv); 
HO.test = test(cv);
end