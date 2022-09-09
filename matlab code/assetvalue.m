function [A,C_t] = assetvalue(data,g,flag)
%INPUT
% data: struct containing market data, such as:
%s:      spread
%N:      Face value of the bond
%S0:     Initial value of the stock
%r:      Spot rates
%T:      Time to maturity
%sigma:  Volatility of the stock
% g:     Monte Carlo Simulation for the stock values.

%
%OUTPUT
%bond:   Value of the bond year by year
%stock:  Value of the stock year by year
%% Value of the Bond


t =(0:data.T)';
B = zeros(data.T+1,1);

discount_0N = exp(-(data.r(end) + data.s )*t(end));
r = [0;data.r];

for i = 1:data.T+1
    
    discount_iN = discount_0N / exp(-(r(i)+data.s)*t(i));
    B(i) = data.N*discount_iN;
end
B(end) = data.N;

%% Computation of the stock with simulation matrix g
[P,M] = size(g);
dt = linspace(0,10,M+1)';

r_interp = zeros(M+1,1);
for i = 1:M+1
    r_interp(i) = interp1(t,r,dt(i));
end

step_t = 10/M;
fwd_rates = - ( (-dt(2:end).*r_interp(2:end) + dt(1:end-1).*r_interp(1:end-1))/step_t);

S_sim = zeros(P,M+1);
S_sim(:,1) = data.S0;

for i= 1:P
    for j = 1:M
        S_sim(i,j+1) = S_sim(i,j) * exp( (fwd_rates(j)- data.sigma^2/2)*step_t + data.sigma * sqrt(step_t)*g(i,j));
    end
end

index = 10*(0:10)+1;
S_t = S_sim(:,index);

%% martingale test

% test=mean(S_t); % test martingale 
% plot(t,test)     % plot si nota il comportamento dello stock come un bond privo di rischio
% xlabel('Years')
% ylabel('Average S(t)')

%% Computation Fund value

F_t = B'.*ones(P,1) + S_t;
A = F_t(1,1);
F_t(:,1) = 1000;

F_prime = F_t(:,2:end) - F_t(:,1:end-1)*data.feeRate;
C_0 = mean(F_t(:,1));

if flag == 1 %case A
    
    C_t = [ C_0, mean(max(F_t(:,1).*ones(P,1), F_prime))]';
    
else    % case B
   
    C_t = [C_0, mean(F_prime)]';
end
    
end