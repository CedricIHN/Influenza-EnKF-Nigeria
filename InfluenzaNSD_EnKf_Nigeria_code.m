function InfluenzaNSD_EnKf_Nigeria_code
 clear; clc; close all
 disp(' Computation has started') 
 format long
 % global parameters
 global L th mu muA xiI xiH gaH dI dRp dAp
 % % Known paremters values
 L = 0*156680; th =0.0191; mu = 0*1/((365/7)*64.74); gaH = 0.750; dI = 0.0015;
 xiI = 0.45; xiH = 0.350; muA = 0.8;
 dRp = th+mu;
 dAp = muA;
 % % % Simulation
 h = 1; %step
 N = 130; % Ensemble umber
 Nx = 5;
 Np = 7 ; % Number unknown parameters
 % % % Data
 mt = 12; % remaining data of test
 mf = 54; %time forecast
 m = mt+mf;
 % % Range of data
 step = 1; % step save result
 
 dates = {'03-Jul-2023';'10-Jul-2023';'17-Jul-2023';'24-Jul-2023';'31-Jul-2023';'07-Aug-2023';'14-Aug-2023';...
     '21-Aug-2023';'28-Aug-2023';'04-Sep-2023';'11-Sep-2023';'18-Sep-2023';'25-Sep-2023';'02-Oct-2023';...
     '09-Oct-2023';'16-Oct-2023';'23-Oct-2023';'30-Oct-2023';'06-Nov-2023';'13-Nov-2023';'20-Nov-2023';...
     '27-Nov-2023';'04-Dec-2023';'11-Dec-2023';'18-Dec-2023';'25-Dec-2023';'01-Jan-2024';'08-Jan-2024';...
     '15-Jan-2024';'22-Jan-2024';'29-Jan-2024';'05-Feb-2024';'12-Feb-2024';'19-Feb-2024';'26-Feb-2024';...
     '04-Mar-2024';'11-Mar-2024';'18-Mar-2024';'25-Mar-2024';'01-Apr-2024';'08-Apr-2024';'15-Apr-2024';...
     '22-Apr-2024';'29-Apr-2024';'06-May-2024';'13-May-2024';'20-May-2024';'27-May-2024';'03-Jun-2024';...
     '10-Jun-2024';'17-Jun-2024';'24-Jun-2024';'01-Jul-2024';'08-Jul-2024';'15-Jul-2024';'22-Jul-2024';...
     '29-Jul-2024';'05-Aug-2024';'12-Aug-2024';'19-Aug-2024';'26-Aug-2024';'02-Sep-2024';'09-Sep-2024';...
     '16-Sep-2024';'23-Sep-2024';'30-Sep-2024';'07-Oct-2024';'14-Oct-2024';'21-Oct-2024';'28-Oct-2024';...
     '04-Nov-2024';'11-Nov-2024';'18-Nov-2024';'25-Nov-2024';'02-Dec-2024';'09-Dec-2024';'16-Dec-2024';...
     '23-Dec-2024';'30-Dec-2024';'06-Jan-2025';'13-Jan-2025';'20-Jan-2025';'27-Jan-2025';'03-Feb-2025';...
     '10-Feb-2025';'17-Feb-2025';'24-Feb-2025';'03-Mar-2025';'10-Mar-2025';'17-Mar-2025';'24-Mar-2025';...
     '31-Mar-2025';'07-Apr-2025';'14-Apr-2025';'21-Apr-2025';'28-Apr-2025';'05-May-2025';'12-May-2025';...
     '19-May-2025';'26-May-2025';'02-Jun-2025';'09-Jun-2025';'16-Jun-2025';'23-Jun-2025';'30-Jun-2025';...
     '07-Jul-2025';'14-Jul-2025';'21-Jul-2025';'28-Jul-2025';'04-Aug-2025';'11-Aug-2025';'18-Aug-2025';...
     '25-Aug-2025';'01-Sep-2025';'08-Sep-2025';'15-Sep-2025';'22-Sep-2025';'29-Sep-2025';'06-Oct-2025';...
     '13-Oct-2025';'20-Oct-2025';'27-Oct-2025';'03-Nov-2025';'10-Nov-2025';'17-Nov-2025';'24-Nov-2025';...
     '01-Dec-2025';'08-Dec-2025';'15-Dec-2025';'22-Dec-2025';'29-Dec-2025';'05-Jan-2026';'12-Jan-2026';...
     '19-Jan-2026';'26-Jan-2026';'02-Feb-2026';'09-Feb-2026';'16-Feb-2026';'23-Feb-2026';'02-Mar-2026';...
     '09-Mar-2026';'16-Mar-2026';'23-Mar-2026';'30-Mar-2026';'06-Apr-2026';'13-Apr-2026';'20-Apr-2026';...
     '27-Apr-2026';'04-May-2026';'11-May-2026';'18-May-2026';'25-May-2026';'01-Jun-2026';'08-Jun-2026';...
     '15-Jun-2026';'22-Jun-2026'};

 % cases, hospitalized and death
 Y1 = [144872; 36735;35672;35886;35187;38811;41253;58221;86008;172520;422020;1028470;1913474;2650704;2418316;...
     2397804;1113412;772092;293943;82928;63531;90341;133802;195031;360087;445655;573265;416696;199480;86023;47390;...
     42475;35686;34941;31274;34537;33313;34273;33666;33949;35690;36402;35480;33037;33014;32099;32658;35691;...
     36282;33086;33649;34304;34774;9141;8447;8903;9122;9252;9370;11942;18182;36584;98648;327119;932286;2402514;...
     4351261;4408272;3554352;2512026;1513462;420664;87112;31157;38154;78014;216220;510970;1272581;2286157;2881605;...
     1995662;911678;225252;41704;12051;8701;8748;8014;8632;8329;7757;8085;8479;8046;7648;9049;8924;7782;8827;8612;...
     8495;8905;8720;98934;23925;27587;28483;24937;28747;30877;31993;40765;65401;139005;378028;963873;2081132;...
     3583057;3424779;3170345;2202896;1029747;395821;143250;104327;128543;238307;398390;703147;831576;790889;...
     390976;140261;45983;32184;26922;26023;24437;26292;28414;26974;28330;26582;25437;24950;27236;22601;28432;...
     25302;27169;26214;24425;26909;24832;23608]';
 Y2 = [2132;538;515;555;536;591;676;828;1456;2755;7110;15690;31757;45731;41152;33278;18852;10611;2922;1199;935;...
     1315;1926;3187;5343;6888;7914;5835;2791;1282;685;565;536;481;454;491;452;501;477;576;492;493;470;454;524;591;...
     462;508;486;565;516;508;476;122;124;123;134;124;179;190;325;646;1601;4759;16752;40545;58693;71090;55301;31367;...
     15842;5490;1331;470;576;1191;2813;6971;18761;33821;39102;27129;13033;3426;631;150;145;111;122;114;136;121;123;...
     143;120;137;112;141;105;103;145;134;127;130;1599;433;374;354;453;394;459;449;704;1114;2478;6030;14717;29444;...
     50765;52855;44046;30169;14972;6007;1942;1303;1964;3822;6610;10603;14021;13069;5521;2096;719;376;391;382;344;...
     404;368;345;408;405;379;384;400;414;406;401;444;354;384;406;346;406]';
 Y3 = [201;55;46;51;59;46;73;70;122;211;515;1170;2380;3272;3788;3385;2389;1110;480;159;105;144;216;306;532;673;718;...
     577;248;117;72;62;62;57;43;53;62;55;51;66;62;67;55;70;60;36;38;67;48;42;60;37;48;11;9;12;14;7;17;17;21;49;128;...
     406;1135;2513;4824;5695;4823;4007;2048;891;153;46;46;133;306;783;1832;3355;3843;3183;1389;373;59;12;15;7;9;13;...
     12;18;17;12;10;16;12;15;9;15;13;6;8;17;169;22;45;41;28;37;36;43;44;97;165;401;1229;2014;3927;5344;4647;2973;...
     1665;629;216;154;195;348;696;1112;1410;1203;616;220;64;45;29;47;43;38;45;46;39;31;30;42;37;37;36;46;39;37;34;...
     41;36;35]';
 Y = [Y1; Y2; Y3];
 % % % ***********************
 M = length(Y(1,:))-mt; % length of data used for estimation
 Nd = size(Y,1);
 dt = 0:1:M+m;
 %%%%%%%%%%%%   *****************
 % % white noises and covariance
 % States
 qws = 0.0015; qwi = 0.0015; qwh = 0.0015; qwr = 0.0015; qwa = 0.0015;
 % Parameters
 qbh = 1e-5; qep = 1e-5; qba = 1e-5;
 qa = 1e-5; qp = 1e-5; qsig = 1e-5; qdH = 1e-5;
 % Observation
 qv1 = 584.72; % New cases
 qv2 = 25.72; % New hospitalized cases
 qv3 = 16.72; % New deceased
 %
 Qw = 10000*diag([qws qwi qwh qwr qwa]);
 Qeta = diag([qbh qep qba qa qp qsig qdH]);
 Qv = diag([qv1, qv2, qv3]);
 %
 % Initialisation of estimate states and estimate parameters
 New_cases = zeros(1,M+m); New_Hosp = zeros(1,M+m);
 New_death = zeros(1,M+m);
 EstX = zeros(Nx,M+m); EstB = zeros(Np,M+m); Bh = zeros(1,M+m);
 EstB_min = zeros(Np,M+m); EstB_max = zeros(Np,M+m);
 Iac = zeros(1,M+m); % Active cases
 Iah = zeros(1,M+m); % Active hospitalized
 % error
 Er1 = zeros(1,M+m); 
 Er2 = zeros(1,M+m);
 Er3 = zeros(1,M+m);
 %
 S = 229501935;
 I = Y(1,1);
 H = Y(2,1);
 R = 0;
 A = 5e+3;
 Inix = [S; I; H; R; A];
 EstX(:,1) = Inix(:,1);
 Iac(1,1) = EstX(2,1);
 Iah(1,1) = EstX(3,1);
 % % DFE
 S0 = 0; % L/mu;
 % Initialisation of estimated parameter (prior values) 
 disp('Initialisation of estimated parameters (prior values)') 
 % % priori values of estimated parameters
          
 bhe = 0.01;
 epe = 0.01;
 bae = 0.08;
 ae = 0.045;
 %
%  bhe = 0.006989330959550;
%  epe = 0.064963693602492;
%  bae = 0.000937263763170;
%  ae = 0.046347047209112;
 pe = 0.029432878679110;
 sige = 0.5;
 dHe = 0.094;
 % cbh="0.01" cep="0.5" cba="0.001" ca="0.1
 cbh = 0.01; cep = 0.1; cba = 0.01; ca = 0.1;
%  cp = 0.01; csig = 0.1; cdh = 0.01;
 % Best initials parameters values
 y = EstX(:,1);
 Nt = sum(y(1:4));
 lam =  (bhe*(y(2)+epe*y(3))/Nt)+bae*ae*y(5)/(1+ae*y(5));
 ydc1 = lam*y(1);
 ydh1 = pe*sige*y(2);
 ydd1 = dHe*y(3);
 par = [bhe epe bae ae pe sige dHe];
 ydc = ydc1; ydh = ydh1; ydd = ydd1;
 kp = 1;
 while kp<=2*N
    while (abs(ydc-Y(1,1))>0.5)
        bhe = cbh*rand; epe = cep*rand; bae = cba*rand; ae = ca*rand;
%         pe = cp*rand; sige = csig*rand; dHe = cdh*rand;
        lam = (bhe*(y(2)+epe*y(3))/Nt)+bae*ae*y(5)/(1+ae*y(5));
        ydc = lam*y(1);
%         ydh = pe*sige*y(2);
%         ydd = dHe*y(3);
    end
    par = par+[bhe epe bae ae pe sige dHe];
%     ydc1 = ydc;
    kp = kp+1;
 end
 par = par/(2*N);
 New_cases(1,1) = ydc;
 New_Hosp(1,1) = ydh;
 New_death(1,1) = ydd;
 Bh(1,1) = bhe;
%      par = [bhe bh1e epe bae ae pe sige dHe];
 EstB(:,1) = par';
 disp('************** Initial values of Parameters *****************')
 disp(par);
 % Initial member ensemble  of states
 Xest = zeros(Nx,N);  Best = zeros(Np,N); % exact variable
 %%%% Initial member ensemble  of states and parametes at each period
%  si = 1e-5*eye(Np,Np);
%  Q0 = eye(Nx,Nx);
%  T0 = eye(Np,Np);
%  for i = 1:N
%      Xest(:,i) = Q0*randn(Nx,1)+EstX(:,1);
%      % member 1 of ensemble  of rates
%      Best(:,i) = T0*(si*randn(Np,1))+EstB(:,1);
%  end
 for i = 1:N
     Xest(:,i) = EstX(:,1);
     Best(:,i) = EstB(:,1);
 end
 % 
 %%%%%%%% ***********************************************
 % compute of average of each vector states
 Xebar = zeros(Nx,1);
 % prediction error
 Pxy = zeros(Nx,Nd);
 Pyy = zeros(Nd,Nd);
 %
 Bebar = zeros(Np,1);
 Pxyb = zeros(Np,Nd);
 Pyyb = zeros(Nd,Nd);
 %
 Xe = zeros(Nx,N);     % exact variable
 Be = zeros(Np,N);      % Parameters
 ye1 = zeros(Nd,N);
 ye2 = zeros(Nd,N);
 %
 % % % % % % % % % % % 
 New_cases_ens = zeros(1,N); New_cases_ens(1,1) = ydc;
 New_Hosp_ens = zeros(1,N); New_Hosp_ens(1,1) = ydh;
 New_death_ens = zeros(1,N); New_death_ens(1,1) = ydd;
 % Median forecast
 med_forecast_cases = zeros(1,M+m); med_forecast_cases(1,1) = ydc;
 med_forecast_hosp = zeros(1,M+m); med_forecast_hosp(1,1) = ydh;
 med_forecast_death = zeros(1,M+m); med_forecast_death(1,1) = ydd;
 
 % % % 50% prediction interval (0.25-0.75)
 IP_50_cases = zeros(M+m,2); IP_50_cases(1,:) = ydc*ones(1,2);
 IP_50_hosp = zeros(M+m,2); IP_50_hosp(1,:) = ydh*ones(1,2);
 IP_50_death = zeros(M+m,2); IP_50_death(1,:) = ydd*ones(1,2);

 % 90% prediction interval (0.05-0.95)
 IP_90_cases = zeros(M+m,2); IP_90_cases(1,:) = ydc*ones(1,2);
 IP_90_hosp = zeros(M+m,2); IP_90_hosp(1,:) = ydh*ones(1,2);
 IP_90_death = zeros(M+m,2); IP_90_death(1,:) = ydd*ones(1,2);

 % Quantile forecasts
 q_levels = [0.05, 0.25, 0.50, 0.75, 0.95];
 quantiles_cases = zeros(M+m,5);  quantiles_cases(1,:) = ydc*ones(1,5);
 quantiles_hosp = zeros(M+m,5); quantiles_hosp(1,:) = ydh*ones(1,5);
 quantiles_death = zeros(M+m,5);  quantiles_death(1,:) = ydd*ones(1,5);
 % % % % % % % % % % %
 disp('Ensemble Kalman filter is running...') 
 for k = 2:M
     w = Qw*randn(Nx,N);         % for the states
     v = Qv*randn(Nd,N);         % for data
     eta = Qeta*randn(Np,N);     % for the parameters
     yb = zeros(Nd,N);
     for i = 1:N
        Xe(:,i) = NSD_model(dt(k),Xest(:,i),Best(:,i),h)+w(:,i);
        ye1(:,i) = input_Influenza(dt(k),Xe(:,i),Best(:,i));
     end
     for i = 1:Nx
        Xebar(i,1) = (1/N)*(sum(Xe(i,:)));
     end
     yebar = zeros(Nd,1);
     for i = 1:Nd
         yebar(i,1) = (1/N)*(sum(ye1(i,:)));
     end
     for i = 1:N
         yb(:,i) = Y(:,k)+v(:,i);
     end
     % prediction error
     for i = 1:N
         Exx = Xe(:,i)-Xebar(:,1);
         Eyy = ye1(:,i)-yebar;
         % covariance matrices
         Pxy = Pxy+(1/(N-1))*(Exx*(Eyy'));
         Pyy = Pyy+(1/(N-1))*(Eyy*(Eyy'));
     end
        % estimation of R
        Rb = (1/(N-1))*(v*(v'));

     % Filter gain of Kalman
     Kx = Pxy*(inv((Pyy+Rb)));
     for i = 1:N
         Xest(:,i) = Xe(:,i)+Kx*(yb(:,i)-ye1(:,i));
         for j = 1:Nx
             if Xest(j,i)<0
                 Xest(j,i) = 0;
             end
         end
         % % %
         EstX(:,k) = EstX(:,k)+(1/N)*Xest(:,i);   % estimation of Xk
     end
     % Estimation of each parameter
     for i = 1:N
         Be(:,i) = Best(:,i)+eta(:,i);
         Xe(:,i) = NSD_model(dt(k),EstX(:,k),Be(:,i),h)+w(:,i);
         ye2(:,i) = input_Influenza(dt(k),Xe(:,i),Be(:,i));
     end
     % compute of average of each vector parameter
     for i = 1:Np
       Bebar(i,1) = (1/N)*(sum(Be(i,:)));
     end
     ye2bar = zeros(Nd,1);
     for i = 1:Nd
        ye2bar(i,1) = (1/N)*(sum(ye2(i,:)));
     end
     % prediction error
     for i = 1:N
         Ebb = Be(:,i)-Bebar(:,1);
         Eyyb = ye2(:,i)-ye2bar;
         % covariance matrices
         Pxyb = Pxyb+(1/(N-1))*(Ebb*(Eyyb'));
         Pyyb = Pyyb+(1/(N-1))*(Eyyb*(Eyyb'));
     end
     % Filter gain of Kalman
     Kx = Pxyb*(inv((Pyyb+Rb)));
     for i = 1:N
         B1 = Be(:,i)+Kx*(yb(:,i)-ye2(:,i));
         for j = 1:Np
             Best(j,i) = max(0,min(1,B1(j)));
         end
         EstB(:,k) = EstB(:,k)+(1/N)*Best(:,i);   % estimation of Bk
     end
    EstB_min(:,k) = (min((Best')))';
    EstB_max(:,k) = (max((Best')))';
         %
    bhe = EstB(1,k); epe = EstB(2,k); bae = EstB(3,k); ae = EstB(4,k);
    pe = EstB(5,k); sige = EstB(6,k); dHe = EstB(7,k);
    %
    y = EstX(:,k);
    Nt = sum(y(1:4));
    lam =  (bhe*(y(2)+epe*y(3))/Nt)+bae*ae*y(5)/(1+ae*y(5));
    New_cases(1,k) = lam*y(1);
    New_Hosp(1,k) = pe*sige*y(2);
    Iac(1,k) = Iac(1,k-1)+New_cases(1,k)-(sige+dI+mu)*Iac(1,k-1);
    Iah(1,k) = Iah(1,k-1)+New_Hosp(1,k)-(gaH+dHe+mu)*Iah(1,k-1);
    %
    New_death(1,k) = dHe*y(3);
    
     for i = 1:N
         ye1(:,i) = input_Influenza(dt(k),Xe(:,i),Best(:,i));
         New_cases_ens(1,i) = ye1(1,i);
         New_Hosp_ens(1,i) = ye1(2,i);
         New_death_ens(1,i) = ye1(3,i);
         % % %
     end
     %
     med_forecast_cases(1,k) = quantile(New_cases_ens, 0.50);
     med_forecast_hosp(1,k) = quantile(New_Hosp_ens, 0.50);
     med_forecast_death(1,k) = quantile(New_death_ens, 0.50);
     %
     IP_50_cases(k,:) = quantile(New_cases_ens, [0.25, 0.75]);
     IP_50_hosp(k,:) = quantile(New_Hosp_ens, [0.25, 0.75]);
     IP_50_death(k,:) = quantile(New_death_ens, [0.25, 0.75]);
     % 
     IP_90_cases(k,:) = quantile(New_cases_ens, [0.05, 0.95]);
     IP_90_hosp(k,:) = quantile(New_Hosp_ens, [0.05, 0.95]);
     IP_90_death(k,:) = quantile(New_death_ens, [0.05, 0.95]);
     %
     quantiles_cases(k,:) = quantile(New_cases_ens, q_levels); 
     quantiles_hosp(k,:) = quantile(New_Hosp_ens, q_levels); 
     quantiles_death(k,:) = quantile(New_death_ens, q_levels); 
 end

 disp('Computation of error for estimation') 
 Er1(1,1:M) = abs(Y1(1,1:M)-New_cases(1,1:M)); 
 Er2(1,1:M) = abs(Y2(1,1:M)-New_Hosp(1,1:M)); 
 Er3(1,1:M) = abs(Y3(1,1:M)-New_death(1,1:M)); 
 disp('*************** Error of estimation ***************')
 disp('*************** Mean Absolue Errors of Estimation ***************')
 e11 = mean(Er1(1,1:M)); e12 = mean(Er2(1,1:M)); e13 = mean(Er3(1,1:M));
 disp([e11, e12, e13])
 disp('*************** Mean Squared Errors of Estimation ***************')
 e21 = sqrt(mean(Er1(1,1:M).^2)); e22 = sqrt(mean(Er2(1,1:M).^2));
 e23 = sqrt(mean(Er3(1,1:M).^2));
 disp([e21, e22, e23])

%  %%%%%%%%%% Test and previson  %%%%%%%%%%%%%

 disp('%%%%%%%%%% Test and previson .... %%%%%%%%%%%%%') 
 for k = M+1:M+m
     w = Qw*randn(Nx,N);         % for the states
     eta = Qeta*randn(Np,N);     % for the parameters
     for i = 1:N
        Best(:,i) = Best(:,i) + eta(:,i);
        % 
        for j = 1:Np
            Best(j,i) = max(0, min(1, Best(j,i)));
        end
        
        Xest(:,i) = NSD_model(dt(k), Xest(:,i), Best(:,i), h) + w(:,i);
        Xest(:,i) = max(0, Xest(:,i)); %
        
        % 
        ye2(:,i) = input_Influenza(dt(k), Xest(:,i), Best(:,i));
        New_cases_ens(1,i) = ye2(1,i);
        New_Hosp_ens(1,i)  = ye2(2,i);
        New_death_ens(1,i) = ye2(3,i);
    end
    
    %
    EstX(:,k) = mean(Xest, 2);
    EstB(:,k) = mean(Best, 2);
    
    % Quantiles and forecasts
    med_forecast_cases(1,k) = quantile(New_cases_ens, 0.50);
    med_forecast_hosp(1,k)  = quantile(New_Hosp_ens, 0.50);
    med_forecast_death(1,k) = quantile(New_death_ens, 0.50);
    
    IP_50_cases(k,:) = quantile(New_cases_ens, [0.25, 0.75]);
    IP_50_hosp(k,:)  = quantile(New_Hosp_ens, [0.25, 0.75]);
    IP_50_death(k,:) = quantile(New_death_ens, [0.25, 0.75]);
    
    IP_90_cases(k,:) = quantile(New_cases_ens, [0.05, 0.95]);
    IP_90_hosp(k,:)  = quantile(New_Hosp_ens, [0.05, 0.95]);
    IP_90_death(k,:) = quantile(New_death_ens, [0.05, 0.95]);
    
    quantiles_cases(k,:) = quantile(New_cases_ens, q_levels); 
    quantiles_hosp(k,:)  = quantile(New_Hosp_ens, q_levels); 
    quantiles_death(k,:) = quantile(New_death_ens, q_levels); 
    
    % 
    New_cases(1,k) = mean(New_cases_ens);
    New_Hosp(1,k)  = mean(New_Hosp_ens);
    New_death(1,k) = mean(New_death_ens);
    
    Iac(1,k) = Iac(1,k-1)+New_cases(1,k)-(sige+dI+mu)*Iac(1,k-1);
    Iah(1,k) = Iah(1,k-1)+New_Hosp(1,k)-(gaH+dHe+mu)*Iah(1,k-1);
 end
 
 % % Basic reproduction number
 disp('Computation of the basic reproduction number ***************')
 delI = EstB(6,1:M+mt)+dI+mu;
 delH = gaH+EstB(7,1:M+mt)+mu;
 R0h = Bh(1,1:M+mt).*(1+EstB(2,1:M+mt).*EstB(5,1:M+mt).*EstB(6,1:M+mt)./delH)./delI;
 R0a= (S0/muA)*EstB(3,1:M+mt).*EstB(4,1:M+mt).*(xiI+xiH*EstB(5,1:M+mt).*EstB(6,1:M+mt)./delH)./delI;
 R0 = R0h+R0a;
 % error
 disp('Computation of error for the test values')
 Er1(1,M+1:M+mt) = abs(Y1(1,M+1:M+mt)-New_cases(1,M+1:M+mt)); 
 Er2(1,M+1:M+mt) = abs(Y2(1,M+1:M+mt)-New_Hosp(1,M+1:M+mt)); 
 Er3(1,M+1:M+mt) = abs(Y3(1,M+1:M+mt)-New_death(1,M+1:M+mt));   
 disp('*************** Mean Absolue Errors of test ***************')
 ep11 = mean(Er1(1,M+1:M+mt)); ep12 = mean(Er2(1,M+1:M+mt));
 ep13 = mean(Er3(1,M+1:M+mt));
 disp([ep11, ep12, ep13])
 disp('*************** Mean Squared Errors of test ***************')
 ep21 = sqrt(mean(Er1(1,M+1:M+mt).^2)); ep22 = sqrt(mean(Er2(1,M+1:M+mt).^2));
 ep23 = sqrt(mean(Er3(1,M+1:M+mt).^2));
 disp([ep21, ep22, ep23])

 t = 0:M+m-1;
% 
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstX(1,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} S')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstX(2,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} I')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstX(3,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} H')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstX(4,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14}R')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstX(5,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} A')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstB(1,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} \beta_{h0}')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstB(2,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} \beta_{h1}')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstB(3,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} \epsilon')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstB(4,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} \beta_{a}')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstB(5,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} a')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstB(6,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} p')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstB(7,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} \sigma')
%  
%  figure()
%  grid on
%  hold on
%  plot(t(1:M),EstB(8,1:M),'b','linewidth',2.5,'DisplayName','Data')
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} d_H')
%  
% 
%  figure()
%  grid on
%  hold on
%  plot(t(1,1:M),R0h(1,1:M),'b','linewidth',2.5)
% %  set(gca, 'XTick', ab, 'XTickLabel', name_ab);
%  xtickangle(45)
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} R_{0h}')
% 
%  figure()
%  grid on
%  hold on
%  plot(t(1,1:M),R0a(1,1:M),'b','linewidth',2.5)
% %  set(gca, 'XTick', ab, 'XTickLabel', name_ab);
%  xtickangle(45)
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} R_{0a}')
% 
%  figure()
%  grid on
%  hold on
%  plot(t(1,1:M),R0(1,1:M),'b','linewidth',2.5)
% %  set(gca, 'XTick', ab, 'XTickLabel', name_ab);
%  xtickangle(45)
%  xlabel('\fontsize{14} Time (Week)')
%  ylabel('\fontsize{14} R_0')
% %      title(name)
% %  saveas(gcf, strcat(name,'_rateR0'), 'png')
% %  legend('Location','best')
% % % Save estimated values of states 
 
 figure()
 grid on
 hold on
 plot(t(1:M+mt),Y(1,1:M+mt),'*m','linewidth',2.5,'DisplayName','Data')
 %
 plot(t(1:M+m),quantiles_cases(1:M+m,1),'m','linewidth',2.5,'DisplayName','q5')
 plot(t(1:M),New_cases(1,1:M),'b','linewidth',2.5,'DisplayName','Estimation')
 plot(t(M:M+mt),New_cases(1,M:M+mt),'g','linewidth',2.5,'DisplayName','Test')
 plot(t(M+mt:M+m),New_cases(1,M+mt:M+m),'r','linewidth',2.5,'DisplayName','Forecast')
 plot(t(1:M+m),quantiles_cases(1:M+m,5),'k','linewidth',2.5,'DisplayName','q95')
%      plot(t(M:M+m),Yr1(1,M:M+m),'y','linewidth',2.5,'DisplayName','Control')
%  set(gca, 'XTick', ab, 'XTickLabel', name_ab);
 xtickangle(45)
 xlabel('\fontsize{14} Time (Week)')
 ylabel('\fontsize{14} Newly Reported cases')
 legend('Location','best')
%      title(name)
 legend('Location','best')
%      saveas(gcf, strcat(name,'_fitnewr'), 'png')
% 
 Icc = cumsum(Y(1,1:M+mt)); %%%% Cumulated data
 Imcc = cumsum(New_cases(1,1:M+m)); %%%% Cumulated data

 figure()
 grid on
 hold on
 plot(t(1:M+mt),Icc(1,1:M+mt),'*m','linewidth',2.5,'DisplayName','Data')
 %
 plot(t(1:M),Imcc(1,1:M),'b','linewidth',2.5,'DisplayName','Estimation')
 plot(t(M:M+mt),Imcc(1,M:M+mt),'g','linewidth',2.5,'DisplayName','Test')
 plot(t(M+mt:M+m),Imcc(1,M+mt:M+m),'r','linewidth',2.5,'DisplayName','Forecast')
%      plot(t(M:M+m),Icr1(1,M:M+m),'y','linewidth',2.5,'DisplayName','Control')
%  set(gca, 'XTick', ab, 'XTickLabel', name_ab);
 xtickangle(45)
 xlabel('\fontsize{14} Time (Week)')
 ylabel('\fontsize{14} Reported cumulative cases')
%      title(name)
 legend('Location','best')
%      saveas(gcf, strcat(name,'_fitcumr'), 'png')

 figure()
 grid on
 hold on
 plot(t(1:M+mt),Y(2,1:M+mt),'*m','linewidth',2.5,'DisplayName','Data')
 %
 plot(t(1:M+m),quantiles_hosp(1:M+m,1),'m','linewidth',2.5,'DisplayName','q5')
 plot(t(1:M),New_Hosp(1,1:M),'b','linewidth',2.5,'DisplayName','Estimation')
 plot(t(M:M+mt),New_Hosp(1,M:M+mt),'g','linewidth',2.5,'DisplayName','Test')
 plot(t(M+mt:M+m),New_Hosp(1,M+mt:M+m),'r','linewidth',2.5,'DisplayName','Forecast')
 plot(t(1:M+m),quantiles_hosp(1:M+m,5),'k','linewidth',2.5,'DisplayName','q95')
 %  plot(t(M:M+m),Yr1(1,M:M+m),'y','linewidth',2.5,'DisplayName','Control')
 %  set(gca, 'XTick', ab, 'XTickLabel', name_ab);
 xtickangle(45)
 xlabel('\fontsize{14} Time (Week)')
 ylabel('\fontsize{14} Newly hospitalized cases')
 legend('Location','best')
%      title(name)
 legend('Location','best')
%      saveas(gcf, strcat(name,'_fitnewr'), 'png')
% 
 Ihc = cumsum(Y(2,1:M+mt));
 Imhc = cumsum(New_Hosp(1,1:M+m));

 figure()
 grid on
 hold on
 plot(t(1:M+mt),Ihc(1,1:M+mt),'*m','linewidth',2.5,'DisplayName','Data')
 %
 plot(t(1:M),Imhc(1,1:M),'b','linewidth',2.5,'DisplayName','Estimation')
 plot(t(M:M+mt),Imhc(1,M:M+mt),'g','linewidth',2.5,'DisplayName','Test')
 plot(t(M+mt:M+m),Imhc(1,M+mt:M+m),'r','linewidth',2.5,'DisplayName','Forecast')
%      plot(t(M:M+m),Icr1(1,M:M+m),'y','linewidth',2.5,'DisplayName','Control')
%  set(gca, 'XTick', ab, 'XTickLabel', name_ab);
 xtickangle(45)
 xlabel('\fontsize{14} Time (Week)')
 ylabel('\fontsize{14} Hospitalized cumulative cases')
%      title(name)
 legend('Location','best')
%      saveas(gcf, strcat(name,'_fitcumr'), 'png')

 figure()
 grid on
 hold on
 plot(t(1:M+mt),Y(3,1:M+mt),'*m','linewidth',2.5,'DisplayName','Data')
 % 
 plot(t(1:M+m),quantiles_death(1:M+m,1),'m','linewidth',2.5,'DisplayName','q5')
 plot(t(1:M),New_death(1,1:M),'b','linewidth',2.5,'DisplayName','Estimation')
 plot(t(M:M+mt),New_death(1,M:M+mt),'g','linewidth',2.5,'DisplayName','Test')
 plot(t(M+mt:M+m),New_death(1,M+mt:M+m),'r','linewidth',2.5,'DisplayName','Forecast')
 plot(t(1:M+m),quantiles_death(1:M+m,5),'k','linewidth',2.5,'DisplayName','q95')
%      plot(t(M:M+m),Yr1(1,M:M+m),'y','linewidth',2.5,'DisplayName','Control')
%  set(gca, 'XTick', ab, 'XTickLabel', name_ab);
 xtickangle(45)
 xlabel('\fontsize{14} Time (Week)')
 ylabel('\fontsize{14} Newly deceased')
 legend('Location','best')
%      title(name)
 legend('Location','best')
%      saveas(gcf, strcat(name,'_fitnewr'), 'png')
% 
 Idc = cumsum(Y(3,1:M+mt));
 Imdc = cumsum(New_death(1,1:M+m));

 figure()
 grid on
 hold on
 plot(t(1:M+mt),Idc(1,1:M+mt),'*m','linewidth',2.5,'DisplayName','Data')
 %
 plot(t(1:M),Imdc(1,1:M),'b','linewidth',2.5,'DisplayName','Estimation')
 plot(t(M:M+mt),Imdc(1,M:M+mt),'g','linewidth',2.5,'DisplayName','Test')
 plot(t(M+mt:M+m),Imdc(1,M+mt:M+m),'r','linewidth',2.5,'DisplayName','Forecast')
%      plot(t(M:M+m),Icr1(1,M:M+m),'y','linewidth',2.5,'DisplayName','Control')
%  set(gca, 'XTick', ab, 'XTickLabel', name_ab);
 xtickangle(45)
 xlabel('\fontsize{14} Time (Week)')
 ylabel('\fontsize{14} Cumulative deceased')
%      title(name)
 legend('Location','best')
%      saveas(gcf, strcat(name,'_fitcumr'), 'png')1

%%%%%%%%%%%%%%%%%%%%%%%
% % Save estimated and forecast results
 variable1 = {'beta_h';'epsilon';'beta_A';'a';'p';'sigma';'dH';'R0h';'R0a';'R0';'step';...
     'step1';'M';'mt';'mf';'m'};
 var_error = {'MAE';'MSE'};
 step1 = 8;
 %
 par_col = par(:);
 mean_EstB = mean(EstB(:,1:M), 2);
 final_EstB = EstB(:,M);
 
 col_init  = [par_col; R0h(1); R0a(1); R0(1); step; step1; M; mt; mf; m];
 col_mean  = [mean_EstB; mean(R0h); mean(R0a); mean(R0); step; step1; M; mt; mf; m];
 col_final = [final_EstB; R0h(end); R0a(end); R0(end); step; step1; M; mt; mf; m];

 Tab1 = table(variable1, col_init, col_mean, col_final, ...
     'VariableNames', {'Name', 'initial_values', 'mean_values', 'final_values'});
 %
 dates_dt = datetime(dates, 'InputFormat', 'dd-MMM-yyyy');

 %  Additional date to reach the end date of forecast (M + m)
 data_length = M + m;
 if length(dates_dt) < data_length
    last_date = dates_dt(end);
    n_extra = data_length - length(dates_dt);
    % 7 day for 1 week 
    extra_dates = last_date + calweeks(1:n_extra)';
    dates_dt = [dates_dt; extra_dates];
 end

 %
 dates_all = cellstr(datestr(dates_dt, 'dd-mmm-yyyy'));
 dates_fit = dates_all(1:M+mt);

 Tab2 = table(dates_fit, EstB(1,1:M+mt)', EstB(2,1:M+mt)', EstB(3,1:M+mt)', EstB(4,1:M+mt)', ...
     EstB(5,1:M+mt)', EstB(6,1:M+mt)', EstB(7,1:M+mt)', ...
     R0h(1,1:M+mt)', R0a(1,1:M+mt)', R0(1,1:M+mt)', Bh(1,1:M+mt)',...
     'VariableNames', {'Weeks', 'beta_h','epsilon','beta_A','a','p','sigma','dH','R0h','R0a','R0','betah'});

 Tab3 = table(dates_all, EstX(1,1:length(dates_all))', EstX(2,1:length(dates_all))', ...
     EstX(3,1:length(dates_all))', EstX(4,1:length(dates_all))', EstX(5,1:length(dates_all))', ...
     'VariableNames', {'Weeks', 'S','I','H','R','A'});

 Y1_pad = [Y1(1,1:M+mt)'; zeros(mf,1)];
 Y2_pad = [Y2(1,1:M+mt)'; zeros(mf,1)];
 Y3_pad = [Y3(1,1:M+mt)'; zeros(mf,1)];

 Tab4 = table(dates_all, Y1_pad(1:length(dates_all)), New_cases(1,1:length(dates_all))', 'VariableNames', ...
     {'Weeks', 'data', 'model'});
 Tab5 = table(dates_all, Y2_pad(1:length(dates_all)), New_Hosp(1,1:length(dates_all))', 'VariableNames', ...
     {'Weeks', 'data', 'model'});
 Tab6 = table(dates_all, Y3_pad(1:length(dates_all)), New_death(1,1:length(dates_all))', 'VariableNames', ...
     {'Weeks', 'data', 'model'});
 Tab7 = table(dates_all, med_forecast_cases(1:length(dates_all))', med_forecast_hosp(1,1:length(dates_all))',...
     med_forecast_death(1,1:length(dates_all))','VariableNames',{'Weeks', 'med_forecast_cases', ...
     'med_forecast_Hosp','med_forecast_death'});
 Tab8 = table(dates_all, quantiles_cases(1:length(dates_all),1), quantiles_cases(1:length(dates_all),2), ...
     quantiles_cases(1:length(dates_all),3), quantiles_cases(1:length(dates_all),4),...
     quantiles_cases(1:length(dates_all),5), 'VariableNames', {'Weeks', 'q5', 'q25', 'q50', 'q75', 'q95',});
 Tab9 = table(dates_all, quantiles_hosp(1:length(dates_all),1), quantiles_hosp(1:length(dates_all),2), ...
     quantiles_hosp(1:length(dates_all),3), quantiles_hosp(1:length(dates_all),4),...
     quantiles_hosp(1:length(dates_all),5), 'VariableNames',  {'Weeks', 'q5', 'q25', 'q50', 'q75', 'q95',});
 Tab10 = table(dates_all, quantiles_death(1:length(dates_all),1), quantiles_death(1:length(dates_all),2), ...
     quantiles_death(1:length(dates_all),3), quantiles_death(1:length(dates_all),4), ...
     quantiles_death(1:length(dates_all),5), 'VariableNames', {'Weeks', 'q5', 'q25', 'q50', 'q75', 'q95',});
 Tab11 = table(var_error, ...
     [e11; e21], [e12; e22], [e13; e23], ...
     [ep11; ep21], [ep12; ep22], [ep13; ep23], ...
     'VariableNames', {'Error_Type', 'Cases_Est', 'Hosp_Est', 'Death_Est', 'Cases_Test', 'Hosp_Test', 'Death_Test'});

 % Exportation to Excel
 excel_name = strcat('Result_Fitting_Influenza_cste.xlsx');
 writetable(Tab1,  excel_name, 'Sheet', 'Average_estimation');
 writetable(Tab2,  excel_name, 'Sheet', 'Estimated_parameters');
 writetable(Tab3,  excel_name, 'Sheet', 'Estimated_states');
 writetable(Tab4,  excel_name, 'Sheet', 'Estimated_cases');
 writetable(Tab5,  excel_name, 'Sheet', 'Estimated_hospitalized');
 writetable(Tab6,  excel_name, 'Sheet', 'Estimated_death');
 writetable(Tab7,  excel_name, 'Sheet', 'median_Esti_forecast');
 writetable(Tab8,  excel_name, 'Sheet', 'quantiles_cases');
 writetable(Tab9,  excel_name, 'Sheet', 'quantiles_hosp');
 writetable(Tab10,  excel_name, 'Sheet', 'quantiles_death');
 writetable(Tab11, excel_name, 'Sheet', 'Estimation_error');
end
%%%% ****************************************
function zp = NSD_model(~,y,bt,h)
 global L th mu xiI xiH gaH dI dRp dAp
 %
 bhe = bt(1,1); epe = bt(2,1); bae = bt(3,1); ae = bt(4,1);
 pe = bt(5,1); sige = bt(6,1); dHe = bt(7,1);
 % Non standard scheme of the ODE
 Nt = sum(y(1:4));
 lam =  (bhe*(y(2)+epe*y(3))/Nt)+bae*ae*y(5)/(1+ae*y(5));
 %
 dSp = lam+mu; dIp = sige+dI+mu; dHp = gaH+dHe+mu;
 ke = max([dSp dIp dHp dRp dAp]);
 nsd = (1-exp(-ke*h))/ke;
 %
 yp(1) = (y(1)+nsd*(L+th*y(4)))/(1+nsd*dSp);
 yp(2) = (y(2)+nsd*lam*y(1))/(1+nsd*dIp);
 yp(3) = (y(3)+nsd*pe*sige*y(2))/(1+nsd*dHp);
 yp(4) = (y(4)+nsd*((1-pe)*sige*y(2)+gaH*y(3)))/(1+nsd*dRp);
 yp(5) = (y(5)+nsd*(xiI*y(2)+xiH*y(3)))/(1+nsd*dAp);
 zp = yp';
end
%%%% ******************************************
function yp = input_Influenza(~,y,bt)
 %
 bhe = bt(1,1); epe = bt(2,1); bae = bt(3,1); ae = bt(4,1);
 pe = bt(5,1); sige = bt(6,1); dHe = bt(7,1);
 %
 Nt = sum(y(1:4));
 lam =  (bhe*(y(2)+epe*y(3))/Nt)+bae*ae*y(5)/(1+ae*y(5));
 yp(1) = lam*y(1);
 yp(2) = pe*sige*y(2);
 yp(3) = dHe*y(3);
end
%%%% ******************************************