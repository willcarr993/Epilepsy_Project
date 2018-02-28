function output = NewCreateOrder(subjnum)

%{

CS: 12/22/17

This program is a modification of CreateOrderLagBins_0_180.  

The goal is to make the order files needed for the MST_Psychopy continuous
version.  I'm too lazy to recode this in Python ;)

Here, we have the need for an easier version so that folks with MST or
moderate AD might have a chance.  We're running:

32 pairs of target-repeat
32 pairs of target-lure
32 extras

It sets up a global variable 'order', 
with lags of 0-9 (short lag), 20-80 (medium lag),and 120-180 (long lag)
between 1st and 2nd Repeat or Lure. 
It also sets up a gobal variable 'orderLag', which specifies the lag for a particular trial 
(offset by +500 to distinguish them from 0s for 1sts and foils).

Lags are defined as the number of intervening items between 1st and 2nd position
of a repeat or a lure (e.g., R2 position = 2, then lag = 1 (one intervening item
between R1 and R2).

It first places a predetermined number of 0-lags (here nlags0 = 8), 
then it place the remaining trials involving 2nd R or L lags 2-9


This script will automatically run when you run ExpONSLagBins_0_180.m 

AJ 3/2012

modified 3/21/2012, AJ: fixed bug that added duplicate entries in 'order'

CS 7/10/12
- Cleaned up 0-lag initial placement to prevent failures there
- Cleaned up medium and long-lag initial placement to prevent simple fails
- Checked down to 96 foils and works most of the time.  48 works about 1/3 of the time
- Returning a "good" flag that will let the calling prog know if it worked

CS 12/22/17
- Turned into this short-only version

%}

%rand('state',seed); % reset random seed
%rand('state',sum(100*clock));
%rng('shuffle');

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

% counters
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

% 
%%Output
output(:,1) = order;
output(:,2) = orderlag;
assignin('base', 'output', output);
