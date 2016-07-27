
function [output]=softmaxOwn(input,beta) 
%%
%Softmax decision rule instead of matching law.
%Input the difference value based on the two local incomes.
%Output the 
%xval=linspace(-0.5,0.5,100);

output=1/(1+exp(-(input)*beta));


% figure(1),clf
% hold on;
% for i =1:100
%     plot(xval(i),1/(1+exp(-xval(i)*5)),'o')
% end

end
