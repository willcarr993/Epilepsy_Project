function output = NewCreateOrder(subjnum)

%{
 Written on 28/02/2018 WJC
 Code which generates an order file in the same format as
 CreateOrder_AllShort.m but with a different method of defining the lag and
 population of the order. The lag between repeat and lure pairs have a mean
 and standard deviation, the order is populated one by one with the paired
 images, the foil images then fill the gaps

The format of the output of this function is in keeping with the original
format which is:

1st column of output:
The image number (which corresponds to an image in Set C/Set D etc) with an
added shifting which represents the image type:
+0 : 1st of a repeat pair
+100 : 2nd of a repeat pair
+200 : 1st of a lure pair
+300 : 2nd of a lure pair
+400 : foil image

2nd column:
if == -1 : is either a foil or 1st presentation of repeat/lure pair
if > 500 : is a 2nd presentation of a repeat/lure pair, the value shown is
the lag + 500.

%}

nlurepairs = 32;
nreppairs = nlurepairs;
nfoils = 64; 
min_lag = 0; % uses a random number generator, need to set min and max values
max_lag = 80;
lagmean = 30;
lagsd = 20;

% For Testing
% nlurepairs = 32;
% nreppairs = nlurepairs;
% nfoils = 64;
% min_lag = 0; 
% max_lag = 60; 
% lagmean = 30;
% lagsd = 20;

ntrials = 2*(nreppairs + nlurepairs) + nfoils; 

% creating order arrays and image orders
rng(subjnum);
repeat_order = randperm(nreppairs);
lure_order = randperm(nlurepairs);
foil_order = randperm(nfoils);
order = zeros(ntrials,1);  % when eventually populated, forms 1st column of output
orderlag = zeros(ntrials,1); % when eventually populated, forms 2nd column of output
orderlag = orderlag - 1;
spaces_list = 1:ntrials; % is used to know the places in the order which have already been taken up by images
output = zeros(ntrials,2);


%% Populate order with repeat and lure pairs
for i=1:nreppairs
    %Insert repeat pair
    replag = 0;
    repposi = 0;
    % this while loop sees if the potential position for the 1st and 2nd
    % presentation of an image pair are available
    while ~ismember(repposi,spaces_list) || ~ismember(repposi+replag+1,spaces_list)
        replag = round(normrnd(lagmean,lagsd));
        if replag < min_lag
            replag = min_lag;
        elseif replag > max_lag
            replag = max_lag;
        end
        repposi = randi([1 (ntrials-(replag+1))]);
    end
    % Once you know the positions are available, populate and remove those
    % positions from spaces_list
    order(repposi) = repeat_order(i);
    order(repposi+replag+1) = repeat_order(i)+100;
    orderlag(repposi+replag+1) = replag+500;
    
    spaces_list(spaces_list==repposi) = [];
    spaces_list(spaces_list==(repposi+replag+1)) = [];
        
    %Insert lure pair
    lurelag = 0;
    lureposi = 0;
    while ~ismember(lureposi,spaces_list) || ~ismember(lureposi+lurelag+1,spaces_list)
        lurelag = round(normrnd(lagmean,lagsd));
        if lurelag < min_lag
            lurelag = min_lag;
        elseif lurelag > max_lag
            lurelag = max_lag;
        end
        lureposi = randi([1 (ntrials-(lurelag+1))]);
    end
    order(lureposi) = lure_order(i)+200;
    order(lureposi+lurelag+1) = lure_order(i)+300;
    orderlag(lureposi+lurelag+1) = lurelag+500;
    
    spaces_list(spaces_list==lureposi) = [];
    spaces_list(spaces_list==(lureposi+lurelag+1)) = [];
    
end
%% Now go and fill in the foils
foil_spaces = find(order==0);
if length(foil_spaces) ~= nfoils
    fprintf('The number of spaces for foils is not equal to the number of foils, something has gone wrong!')
    return
end

for i=1:nfoils
    order(foil_spaces(i)) = foil_order(i) + 400;
end

%% Output
output(:,1) = order;
output(:,2) = orderlag;
