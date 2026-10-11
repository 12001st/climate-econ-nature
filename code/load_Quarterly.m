clear all; clear session; close all; clc
warning off all

% 1. Load data
[data, vnames] = xlsread('data/data_Quarterly_1981_2022_final.xlsx','data','D1:AR2353');

date = 1981:1/4:2022+3/4;
date = date';
nvar = length(vnames);
nstate = 14;
nobs = size(data,1)/nstate;

% Store variables in the structure DATA
for jj=1:nstate
    for ii=1:length(vnames)
        DATA(jj).(vnames{ii}) = data((jj-1)*nobs+1:jj*nobs,ii);
    end
end

% Create two more variables; interest rate spread, trade balance
for jj=1:nstate 
        DATA(jj).ir_spread = DATA(jj).ir_lending - DATA(jj).ir_deposit;
        DATA(jj).tbal = DATA(jj).xport - DATA(jj).mport;
end

% {'hcpi','ccpi','fcpi','ecpi','ppi','def','ip','uempr','ir_deposit','ir_lending','npl','ep','xr','xport','mport'}
% {'ngdp_us','rgdp','rgdp_con','rgdp_inv','rgdp_govc','rgdp_agri','rgdp_indust','rgdp_serv'}
% {'hot_mean','cold_mean','drought_mean','prep_mean','wind_mean','AECI_mean','hot_max','cold_max','drought_max','prep_max','wind_max','AECI_max'}
% {'vix','totcom','energy','agri','usip','usrgdp'}

% Transform selected variables
% temptreat = {'logdiff','diff','rate'};
% tempscale = [100,100,1];

tempnames = {'hcpi','ccpi','fcpi','ecpi','ppi','def','ip','uempr','ir_deposit','ir_lending','ep','xr','xport','mport', ...
    'ngdp_us','rgdp','rgdp_con','rgdp_inv','rgdp_govc','rgdp_agri','rgdp_indust','rgdp_serv', ...
    'totcom','energy','agri','usip','usrgdp','tbal'};
for jj=1:nstate
    for ii=1:length(tempnames)
        aux = {['d' tempnames{ii}]};
        DATA(jj).(aux{1}) = 100*XoX(DATA(jj).(tempnames{ii}),1,'rate'); % QoQ
    end
end

for jj=1:nstate
    for ii=1:length(tempnames)
        aux = {['d4' tempnames{ii}]};
        DATA(jj).(aux{1}) = 100*XoX(DATA(jj).(tempnames{ii}),4,'rate'); % YoY annualized growth rate
    end
end


% Create new variables: adjustment speed in trade balance
for jj=1:nstate 
    DATA(jj).dtbaladj = DATA(jj).dxport - DATA(jj).dmport;    
    DATA(jj).d4tbaladj = DATA(jj).d4xport - DATA(jj).d4mport;
end


tempnames = {'ir_deposit','ir_lending','ir_spread','uempr','npl','vix'};
for jj=1:nstate
    for ii=1:length(tempnames)
        aux = {['d' tempnames{ii}]};
        DATA(jj).(aux{1}) = XoX(DATA(jj).(tempnames{ii}),1,'diff'); % QoQ difference
    end
end

for jj=1:nstate
    for ii=1:length(tempnames)
        aux = {['d4' tempnames{ii}]};
        DATA(jj).(aux{1}) = XoX(DATA(jj).(tempnames{ii}),4,'diff'); % YoY difference
    end
end


tempnames = {'hot_mean','cold_mean','drought_mean','prep_mean','wind_mean','AECI_mean','hot_max','cold_max','drought_max','prep_max','wind_max','AECI_max'};
for jj=1:nstate 
    for ii=1:length(tempnames)
        aux = {['mv4' tempnames{ii}]};
        DATA(jj).(aux{1}) = MovAvg(DATA(jj).(tempnames{ii}),4);
    end
end

clear temp*