function output = NewCreateOrder(subjnum)

%{
 Written on 28/02/2018
 Code which generates an order file in the same format as
 CreateOrder_AllShort.m but with a different method of defining the lag and
 population of the order. The lag between repeat and lure pairs have a mean
 and standard deviation, the order is populated one by one with the paired
 images, the foil images then fill the gaps
%}

% Code to tell you what type of image it is
% Offset_1R = 0; % 1-100 1st of repeat pair
% Offset_2R = 100; % 101-200  2nd of repeat pair
% Offset_1L = 200; % 201-300 1st of lure pair
% Offset_2L = 300; % 301-400 2nd of lure pair
% Offset_Foil = 400; % 401+ Foil

nlurepairs = 32;
nreppairs = nlurepairs;
nfoils = 64; % May fail some times with this # but works most of the time...
min_lag = 0; % For non-zero, what's the min gap?
max_lag = 60; % For non-zero, what's the max gap?
lagmean = 30;
lagsd = 20;

% For Testing
% nlurepairs = 32;
% nreppairs = nlurepairs;
% nfoils = 64; % May fail some times with this # but works most of the time...
% min_lag = 0; % For non-zero, what's the min gap?
% max_lag = 60; % For non-zero, what's the max gap?
% lagmean = 30;
% lagsd = 20;

ntrials = 2*(nreppairs + nlurepairs) + nfoils; 

% creating order arrays and image orders
rng(subjnum);
repeat_order = randperm(nreppairs); % for 2nd pres Repeats
lure_order = randperm(nlurepairs); % for 2nd pres Lures
foil_order = randperm(nfoils); %
order = zeros(ntrials,1);  % actual array of trial order / types -- start at 0 -- see above for codes
orderlag = zeros(ntrials,1); % array of lags (-1s for 1sts and foils; lags for 2nd presentations).
orderlag = orderlag - 1;
spaces_list = 1:ntrials;
output = zeros(ntrials,2);


%% Populate order with repeat and lure pairs
for i=1:nreppairs
    %Insert repeat pair
    replag = 0;
    repposi = 0;
    while ~ismember(repposi,spaces_list) || ~ismember(repposi+replag+1,spaces_list)
        replag = round(normrnd(lagmean,lagsd));
        if replag < min_lag
            replag = min_lag;
        elseif replag > max_lag
            replag = max_lag;
        end
        repposi = randi([1 (ntrials-(replag+1))]);
    end
    order(repposi) = repeat_order(i);
    order(repposi+replag+1) = repeat_order(i)+100;
    orderlag(repposi+replag+1) = replag+500;
    
    spaces_list(spaces_list==repposi) = [];
    spaces_list(spaces_list==(repposi+replag+1)) = [];
        
    %Insert foil pair
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