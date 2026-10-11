%load_Monthly; % call first

close all

outdir = 'output/Monthly';

 % Benchmark [aci, y, p, u, r, fx, ep] 
 % where y = {ip, and/or xport} p = {hcpi and/or ppi}

%%% 1. Without d12uemp

% 1 BRN = [climate, d12hcpi_m, ir_spread, d12xr]
% 2 KHM = [climate, d12hcpi_m, ir_spread, d12xr]
% 3 IDN = [climate, d12ip, d12hcpi_m, ir_spread, d12xr, d12ep]
% 4 LAO = [climate, d12hcpi_m, ir_spread, d12xr]
% 5 MYS = [climate, d12ip, d12hcpi_m, ir_spread, d12xr, d12ep]
% 6 MMR = [climate, d12hcpi_m, ir_spread, d12xr]
% 7 PHL = [climate, d12ip, d12hcpi_m, ir_spread, d12xr, d12ep] % ip has outliers during the COVID-19
% 8 SGP = [climate, d12ip, d12hcpi_m, ir_spread, d12xr, d12ep]
% 9 THA = [climate, d12hcpi_m, ir_spread, d12xr, d12ep]
% 10 VNM = [climate, d12ip, d12hcpi_m, ir_spread, d12xr, d12ep] % ip only from 2008m1
% 11 CHN = [climate, d12hcpi_m, ir_spread, d12xr, d12ep]
% 12 JPN = [climate, d12ip, d12hcpi_m, ir_spread, d12xr, d12ep]
% 13 KOR = [climate, d12ip, d12hcpi_m, ir_spread, d12xr, d12ep]
% 14 HKG = [climate, d12ip, d12hcpi_m, ir_spread, d12xr, d12ep]

% Group 1: BRN, KHM, LAO, MMR
% Group 2: THA, CHN
% Group 3: IDN, MYS, PHL, SGP, VNM, JPN, KOR


%%% 2. With d12xport, for where d12ip unavailable
% For Group 1, [climate, d12xport, d12hcpi_m, ir_spread, d12xr]
% For Group 2, [climate, d12xport, d12hcpi_m, ir_spread, d12xr, d12ep]


%%% 3. With d12uemp

% MYS = [climate, d12ip, d12umepr, d12hcpi_m, ir_spread, d12xr, d12ep]
% THA = [climate, d12umepr, d12hcpi_m, ir_spread, d12xr, d12ep]
% JPN = [climate, d12ip, d12umepr, d12hcpi_m, ir_spread, d12xr, d12ep]
% KOR = [climate, d12ip, d12umepr, d12hcpi_m, ir_spread, d12xr, d12ep]
% HKG = [climate, d12ip, d12umepr, d12hcpi_m, ir_spread, d12xr, d12ep]



%%%%%%%%%%%%%%%%%%%%%
% modelno = 1; [climate, d12hcpi_m, ir_spread, d12xr]; countryid = ALL
% modelno = 2; [climate, d12hcpi_m, ir_spread, d12xr, d12ep] ; countryid = [3, 5, 7, 8, 9, 10, 11, 12, 13, 14]
% modelno = 3; [climate, d12ip, d12hcpi_m, ir_spread, d12xr, d12ep]; % countryid = [3, 5, 7, 8, 10, 12, 13, 14]

%Xvnames = {'AECI','d12ip','d12hcpi_m','d12ppi_m','d12uempr','d12ir_lending','d12xr','d12ep'};
%Xvnames = {'AECI','dip','dhcpi_m','dppi_m','duempr','dir_lending','dxr','dep'};
%Xvnames_long = {'Climate Index','Output Growth','CPI Inflation','PPI Inflation',...
%    'Unemployment Change','Interest Rate','Exchange Rate','Stock Returns'};


countrynames = {'Bruei','Cambodia','Indonesia','Lao','Malaysia','Myanmar','Philippines','Singapore','Thailand','Vietnam','China','Japan','Korea','Hong Kong'};


modelno = 1;

for countryid = 1:14

if modelno == 1   
    
    Xvnames = {'mv12AECI','d12hcpi_m','d12ir_spread','d12xr'};
    Xvnames_long = {'AECI.mv12','CPI Inflation','Interest Rate Spread','Exchange Rate Change'};
    Xnvar = length(Xvnames);


    X0 = nan(nobs,Xnvar);
    for ii=1:Xnvar
        X0(:,ii) = DATA(countryid).(Xvnames{ii});
    end

end


if modelno == 2

    Xvnames = {'cci5','d12ip','d12cpi','r_mm'};
    Xvnames_long = {'Climate Index','Output Growth','CPI Inflation','Interest Rate'};
    Xnvar = length(Xvnames);

    X0 = nan(nobs,Xnvar);
    for ii=1:Xnvar
        X0(:,ii) = DATA.(Xvnames{ii});
    end

end


if modelno == 3

    Xvnames = {'d12ip','d12cpi','r_mm'};
    Xvnames_long = {'Output Growth','CPI Inflation','Interest Rate'};
    Xnvar = length(Xvnames);

    XGvnames = {'cci5'};  % Select exogenous variables
    XGvnames_long = {'Climate Index'};
    XGnvar = length(XGvnames);

    X0 = nan(nobs,Xnvar);
    for ii=1:Xnvar
        X0(:,ii) = DATA.(Xvnames{ii});
    end

    XG0 = nan(nobs,XGnvar);
    for ii=1:XGnvar
        XG0(:,ii) = DATA.(Xvnames{ii});
    end

end


% 3.2 Estimate VAR

X1 = CommonSample(X0);
X = X1;
Xnvar = size(X,2);

det = 2; % Set the deterministic variable in the VAR (1 constant, 2 constant and trend)
nlags = 5; % Set number of lags

[VAR, VARopt] = VARmodel(X,nlags,det); % Estimate VAR by OLS


% 4.1 Update the VARopt structure

VARopt.vnames = Xvnames_long;
VARopt.nsteps = 60;
VARopt.impact = 0; % size the shock: impact 0 -> one stdev shock, 1 -> unitary shock
VARopt.quality = 1;
VARopt.FigSize = [30,18];
VARopt.frequency = 'm';
%VARopt.figname= 'KR/graphics/nv8_det2_lag6_chol_';

%{
if modelno == 1
VARopt.firstdate = date(nobs-length(X1(:,1))+1);  % Find the first observation
end


if modelno == 2
VARopt.firstdate = datesnum(273); % r_mm starting at 1976M8
end
%}

disp(VARopt)



% 4.2 IMPULSE RESPONSES
%-------------------------------------------------------------------------- 
% To get zero contemporaneous restrictions set
VARopt.pctg = 90;
VARopt.ident = 'short';

[IR, VAR] = VARir(VAR,VARopt); % Compute IR
[IRinf,IRsup,IRmed,IRbar] = VARirband(VAR,VARopt); % Compute IR error bands
%VARirplot(IRbar,VARopt,IRinf,IRsup); % Plot IR

figure
FigSize(10,10)
    for ii=1:Xnvar
        subplot(2,2,ii)
        PlotSwathe(IRmed(:,ii,1),[IRinf(:,ii,1) IRsup(:,ii,1)]); 
        hold on
        plot(zeros(VARopt.nsteps),'--k');
        title(Xvnames_long{ii})
        axis tight
    end

    sgtitle(countrynames(countryid),'Color',cmap(1),'FontSize',16);
 
strA=[outdir '/figures/VAR_model_' num2str(modelno) '_id_' num2str(countryid) '_' Xvnames{1} '_Cholesky'];
SaveFigure(strA,1,'png')

end


%{
% 4.3 FORECAST ERROR VARIANCE DECOMPOSITION
[VD, VAR] = VARvd(VAR,VARopt);  % Compute VD
[VDinf,VDsup,VDmed,VDbar] = VARvdband(VAR,VARopt);  % Compute VD error bands
VARvdplot(VDbar,VARopt);  % Plot VD

% 4.4 HISTORICAL DECOMPOSITION
[HD, VAR] = VARhd(VAR,VARopt);  % Compute HD
VARhdplot(HD,VARopt); % Plot HD
%}
