% clear all; clear session; clc
% warning off all
% format short g

%% 1. DATA
%load_Monthly;
close all; clc
outdir = 'output/Monthly';

EPS0 = [];

% Choose country
for kk = [3 5 7 8 9 10 11 12 13 14]

    close all;
       
    countryid = kk;
    countrynames = {'Brunei','Cambodia','Indonesia','Lao','Malaysia','Myanmar','Philippines','Singapore','Thailand','Vietnam','China','Japan','Korea','Hong Kong'};
    
    %% 2. VAR MODEL
    % Economic variables (ENDO)
    XDvnames = {'d12ip','d12hcpi_m','ir_lending'};
    XDvnames_long = {'g','\pi','i'};
    %XDvnames_long = {'IP Growth','Inflation','Lending Rate'};
    XDnvar = length(XDvnames);
    % Economic variables (EXGO)
    XGvnames = {'d12usip','d12totcom'};
    XGvnames_long = {'US IP Growth','Commodity Price Inflation'};
    XGnvar = length(XGvnames);
        
        XD = nan(nobs,XDnvar);
        XG = nan(nobs,XGnvar);
    
        for ii=1:XDnvar
            XD(:,ii) = DATA(countryid).(XDvnames{ii});
        end
    
        for ii=1:XGnvar
            XG(:,ii) = DATA(countryid).(XGvnames{ii});
        end
    
        X0 = [date,XD,XG];
        [X1, fo, lo] = CommonSample(X0);
        dateX = X1(:,1);
        XD = X1(:,2:end-XGnvar);
        XG = X1(:,2+XDnvar:end);
        
    
    % Specify VAR
    det = 2; % (0 no constant; 1 constant; 2 constant and trend; 3 constant and trend^2 [dflt = 0])
    nlags = 4;
    nlags_XG = 3;
    
    % Estimate VAR by OLS
    [VAR, VARopt] = VARmodel(XD,nlags,det,XG,nlags_XG);
    
    % Print at screen the outputs of the VARmodel estimation
    format short
    disp(VAR)
    disp(VAR.F)
    disp(VAR.sigma)
    disp(VARopt)
    
    % Update the VARopt structure with additional details
    VARopt.vnames = XDvnames_long;           % ENDO variable names in plots
    VARopt.vnames_ex = XGvnames_long;        % EXOG variable names in plots
    VARopt.frequency = 'm';                  % frequency of the data
    VARopt.firstdate = dateX(1);          % first date in plots
    disp(VARopt)
    
    % Print at screen VAR coefficients and create table 
    [TABLE, beta] = VARprint(VAR,VARopt,2); % approx = 2; number of decimal digits
    
    %% 3. IDENTIFICATION WITH SIGN RESTRICTIONS
    
    % shock: S  D  M
    SIGN = [ 1, 1, 1;  % Real GDP
            -1, 1, 1;  % Deflator Inflation
             0, 1, -1]; % Lending Rate
    
    % Update the VARopt structure
    VARopt.ident = 'sign';
    VARopt.sr_hor = 3; % the number of horizons to impose the restrictions on
    VARopt.snames = {'\epsilon_{S}','\epsilon_{D}','\epsilon_{M}'}; % shock names
    %VARopt.snames = {'supply shock','demand shock','monetary shock'}; % shock names
    VARopt.impact = 0; % size of the shock: impact 0 -> one stdev shock, 1 -> unitary shock
    
    VARopt.ndraws = 1000;
    VARopt.nsteps = 20;                      % max horizon of IRF
    VARopt.pctg = 68;
    
    VARopt.quality = 1;
    %VARopt.figname= 'figures_det2/sign_';        % folder and file prefix
    VARopt.FigSize = [26 8];                 % size of window (figures)
    
    % Implement sign restrictions identification with SR routine
    SRout = SR(VAR,SIGN,VARopt);
    
    % Plot all Btilde
    figure(1)
    FigSize(18,18)
    for ii = 1:XDnvar
        for jj = 1:length(VARopt.snames)
        subplot(3,3,jj+3*(ii-1))
        plot(squeeze(SRout.IRall(:,ii,jj,:))); hold on
        plot(zeros(VARopt.nsteps),'--k','LineWidth',0.5); hold on
        xlim([1 VARopt.nsteps]);
        strA=[VARopt.snames{jj} '\rightarrow' VARopt.vnames{ii}];
        title(strA)
        end
    end
    sgtitle(countrynames(countryid),'Color',cmap(1),'FontSize',18);
    strA=[outdir '/figures_det' num2str(det) '/id_' num2str(countryid) '_signIRall_' num2str(XDnvar) 'x' num2str(length(VARopt.snames)) '_L' num2str(nlags) '_LX' num2str(nlags_XG) '_det' num2str(det) '_M'];
    SaveFigure(strA,1,'png') % quality: 0 standard, 1 high quality [dflt=0] [double]
    %clf('reset')
    
    % Plot credible intervals
    figure(2)
    FigSize(18,18)
    for ii = 1:XDnvar
        for jj = 1:length(VARopt.snames)
        subplot(3,3,jj+3*(ii-1))
        PlotSwathe(SRout.IRmed(:,ii,jj),[SRout.IRinf(:,ii,jj) SRout.IRsup(:,ii,jj)]);  hold on
        plot(zeros(VARopt.nsteps),'--k','LineWidth',0.5); hold on
        xlim([1 VARopt.nsteps]);
        strA=[VARopt.snames{jj} '\rightarrow' VARopt.vnames{ii}];
        title(strA)
        end
    end
    sgtitle(countrynames(countryid),'Color',cmap(1),'FontSize',18);
    strA=[outdir '/figures_det' num2str(det) '/id_' num2str(countryid) '_signIRmed_' num2str(XDnvar) 'x' num2str(length(VARopt.snames)) '_L' num2str(nlags) '_LX' num2str(nlags_XG) '_det' num2str(det) '_M'];
    SaveFigure(strA,1,'png')
    %clf('reset')
    
    % Compute structural shocks (T x XDnvar)
    eps_sign0 = (SRout.B\VAR.resid')';
    eps_sign1 = [dateX(nlags+1:end), eps_sign0];
    ii = ones(length(date),1)*kk;
    datei = [date, ii];
    dateT = array2table(datei);
    eps_sign1T = array2table(eps_sign1);
    eps_sign2T = outerjoin(dateT,eps_sign1T,'Keys',1,'MergeKeys',true);
    eps_sign2 = table2array(eps_sign2T);
    EPS0 = [EPS0; eps_sign2];  
end

colNames = {'date','countryid','supply','demand','monetary'};
EPS1 = array2table(EPS0,'VariableNames',colNames);
strA=[outdir '/eps_sign_' num2str(XDnvar) 'x' num2str(length(VARopt.snames)) '_L' num2str(nlags) '_LX' num2str(nlags_XG) '_det' num2str(det) '_M.xlsx'];
% writematrix(eps_sign,strA)
writetable(EPS1,strA)
