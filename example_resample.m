addpath('mfilter','mfileslp')

clear all;
ellipse = [1   .05  .05      0    0   0
            1    .04   .04    -0.5  -0.5     0
             1   .03   .03    -.3  -.3   0
          ];     
N=2^8;
Ntheta=100;Ns=N;
th=linspace(0,pi,Ntheta+1);th=th(1:end-1);s=linspace(-1,1,Ns);%initial polar grid
%% Parameters
osfZ=8;
Pgl=precompute_gl(N,th,s,0,1);
Padj=precompute_adj(Pgl,osfZ);

%circle to cut
[x1,x2]=meshgrid(linspace(-1,1,Pgl.N),linspace(-1,1,Pgl.N));circ0=(sqrt(x1.^2+x2.^2)<1-4/Pgl.N)*1.0;

disp('init exact filtered data');
%filtered phantom
[f,ellipse]=phantom(N,ellipse);filter_kind='hamming';%ramp,shepp-logan,cosine,cosine2,hamming,hann
ff=apply_filter_2d_exact(f,filter_kind,ellipse);
ff=ff.*circ0;
%filtered Radon data
h=apply_filter_exact(Ntheta,Ns,filter_kind,ellipse);h=double(h);

%% FBP
frecl=Radjline(h,th,s,N);

%% rec
disp('reconstruction');
frec=fast_radon_lp_adj(h,Pgl,Padj);frec=frec.*circ0;

figure(1);imagesc([frec ff]);title('true and reconstruction');colorbar;axis image
figure(2);imagesc(frec-ff);title('difference');colorbar
norm(abs(frec-ff)/norm(abs(ff),'fro'),'fro')

%% resampling
p=7;q=2;
h=mresample(h,p,q,q/p);     
Ntheta=p*Ntheta/q;Ns=N;
th=linspace(0,pi,Ntheta+1);th=th(1:end-1);s=linspace(-1,1,Ns);%initial polar grid
osfZ=8;
Pgl=precompute_gl(N,th,s,0,1);
Padj=precompute_adj(Pgl,osfZ);
frec=fast_radon_lp_adj(h,Pgl,Padj);frec=frec.*circ0;


figure(3);imagesc([frec ff]);title('true and reconstruction');colorbar;axis image
figure(4);imagesc(frec-ff);title('difference');colorbar
norm(abs(frec-ff)/norm(abs(ff),'fro'),'fro')
