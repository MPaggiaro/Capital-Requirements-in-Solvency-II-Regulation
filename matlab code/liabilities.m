function [liabs,D]=liabilities(data,C)
%INPUTS
%   data: struct containing
% T:        Maturity
% x:        Current age
% r:        Rates 
% fee_rate:      Fee rate
% lapse:   Lapse rate
%   q:        Mortality rates
%   F:        Funds
%
%OUTPUT
%V:        Current value of the liabilities

t = (0:data.T)';
discounts = exp(-data.r.*t(2:end));

% Selection of the mortality rates of interest:
q_x = data.q(data.x+2:data.x+data.T+1); %mortality rates between (ti,ti+1)


%% Computation liabilities

p = [1; cumprod(1 - q_x(1:end-1))];
l = (1-data.lapseRate).^t(1:end-1);
q_x(end) = 1;

if(data.lapseRate == -1)
    % CASE: lapse mass.
    lapse = 0.05;
    lapseMass = 0.4;
    l = (1-lapse).^t(1:end-1);
    V = zeros(size(discounts));
    V(1) = discounts(1)*p(1)*(q_x(1) + (1-q_x(1))*lapseMass)*C(2);
    V(2:end) = discounts(2:end).*p(2:end).*(q_x(2:end) + (1-q_x(2:end))*lapse).*C(3:end)*(1-lapseMass).*l(1:end-1);
    
else 
    V = discounts.*p.*(q_x + (1-q_x)*data.lapseRate).*C(2:end).*l;
end

liabs = sum(V);
%% computation of the duration

D = dot(t(2:end),V)/liabs;

%% computation of the derivative wrt S0 in equity shock case

if(data.S0 == 122)
    V_der = zeros(10,1);
    g = (C(2:end)>1000);
    V_der(1) = discounts(1)*p(1)*(q_x(1) + (1-q_x(1))*data.lapseRate)* g(1)*exp(data.r(1));
  
    for i=2:10
        V_der(i) = (1-data.lapseRate).^(i-1) * discounts(i)*p(i)*(q_x(i) + (1-q_x(i))*data.lapseRate)* g(i)*(exp(data.r(i)*i)-exp(data.r(i-1)*(i-1))*0.015);
    end
    
    der = sum(V_der);
end