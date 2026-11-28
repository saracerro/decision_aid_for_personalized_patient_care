%---------------------- FITNESS FUNCTION -------------------------
function cost = objectiveFunction(feat,label,X,HO)
if sum(X == 1) == 0
  cost = 1;
else
  cost = jwrapperKNN(feat(:, X == 1),label,HO);
end
end

function error = jwrapperKNN(sFeat,label,HO)
k = 5; 
xtrain = sFeat(HO.training == 1,:);
ytrain = label(HO.training == 1); 
xvalid = sFeat(HO.test == 1,:); 
yvalid = label(HO.test == 1); 

Model     = fitcknn(xtrain,ytrain,'NumNeighbors',k); 
pred      = predict(Model,xvalid);
num_valid = length(yvalid); 
correct   = sum(pred == yvalid);
Acc       = correct / num_valid; 
error     = 1 - Acc;
end

