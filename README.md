# matchingModel
Leaky integration model based on S. paper. 

Model_performance is the main model function. It takes a cfg and outputfile as its arguments. 
The cfg needs to contain a range of values for cfg1.beta and cfg1.tau parameters. As well as participant/date ID 
and the path of the ATM and PLA session. The argument outpufile is wherever you want the resulting parameter fits to be stored. 

The dependent functions include, model_body, softmaxOwn and global_matching. 
Model_body, is the main part of the model related computations. 
global_matching, simply extract the reward and choice histories per participant. 
softmaxOwn, is the softmax equation implementation. 




