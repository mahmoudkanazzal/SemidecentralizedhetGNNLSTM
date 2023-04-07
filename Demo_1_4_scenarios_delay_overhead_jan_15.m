clear
warning off
% data: jan-13-2023
n=250;
k=1:5;

lox = randi([1,n],n,2);
proc_delay_1=0.1
proc_delay_2=0.001
proc_delay_3=0.005

% sc1: fully cent.
% 1 fast MP+processing+1 fast MP+ processing
delay_1=((0.01).*k*2+proc_delay_1*k*n)*10^-1;

% sc2: fully decent.
% 1 slow MP+processing+ 1 slow MP+ processing
delay_2=((1).*k*2*10+proc_delay_2*k)*10^-1;

% sc3: hybrid -fixed assign.
% 1 slow MP+processing+ 1 slow MP+ processing
cloudlet_size=25;
costs=comm_cost(250, cloudlet_size, lox);
delay_31=(sum(1*(1).*costs*2)/250/10.*k+proc_delay_3*k*10)*10^-1;

% sc3: hybrid -fixed assign.
% 1 slow MP+processing+ 1 slow MP+ processing
cloudlet_size=50;
costs=comm_cost(250, cloudlet_size, lox);
delay_32=(sum(1*(1).*costs*2)/250/10.*k+proc_delay_3*k*10)*10^-1;


% sc3: hybrid-adaptive assign.
% 1 slow MP+processing+ 1 slow MP+ processing
cloudlet_size=10;
costs=comm_cost_adaptive(250, cloudlet_size, lox);
delay_41=(sum(1*(1).*costs*2)/250/10.*k+proc_delay_3*k*10)*10^-1;

% sc4: hybrid-adaptive assign.
cloudlet_size=20;
costs=comm_cost_adaptive(250, cloudlet_size, lox);
delay_42=(sum(1*(1).*costs*2)/250/10.*k+proc_delay_3*k*10)*10^-1;


figure(3)
clf
semilogy(k, delay_1, '-x', 'LineWidth',1.7)
hold on
semilogy(k, delay_2, '-o', 'LineWidth',1.7)
semilogy(k, delay_31, '-d', 'LineWidth',1.7)
semilogy(k, delay_32, '-d', 'LineWidth',1.7)
semilogy(k, delay_41, '-s', 'LineWidth',1.7)
semilogy(k, delay_42, '-s', 'LineWidth',1.7)
hold off
grid
set(gca,'xtick',1:5)
legend('Cent.', 'Decent.', 'Semi-decent. (10)','Semi-decent. (20)','Semi-decent.-adaptive (10)','Semi-decent.-adaptive (20)','location', 'southeast',  'FontSize', 9)
title('Inference Time Comparison')
ylabel('Delay (ms)')
xlabel('Communication hops')
my_fig_trim_export('inf_time_comp')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cost=comm_cost_adaptive(n, v, lox)

% whos lox
aa=zeros(n,n);
for i=1:n
    aa(lox(i,1), lox(i,2))=1;
end

% semilogy(aa)
% figure(11);
% clf
% imagesc(aa);
% axis off;
tic;
[idx,C] = kmeans([lox(:,1),lox(:,2)],v);
t2=toc;
assign_delay=t2
% whos C
heatmap=zeros(n,n);
for j=1:v
    heatmap(ceil(C(j,1)), ceil(C(j,2)))=1;
end

% figure(22)
% imagesc(heatmap);
% axis off;
% my_fig_trim_export('unfiform_assignment')

% hold on
temp=[];
jj=1;
for i=1:n
    for j=1:n
        temp(jj,:)=[i,j];
        jj=jj+1;
    end
end
% Xtest=[1:100,1:100]
[~,idx_test] = pdist2(C,temp,'euclidean','Smallest',1);

temp2=zeros(n,n);
jj=1;
for i=1:n
    for j=1:n
        temp2(i,j)=idx_test(jj);
        jj=jj+1;
    end
end

[Gmag, Gdir] = imgradient(temp2);
boundaires=Gmag~=0;

aa=zeros(n,n);
for i=1:n
    aa(lox(i,1), lox(i,2))=1;
end

all=aa+boundaires;
all=all>0.001;

figure(2)
clf
imagesc(all)
axis off;
my_fig_trim_export('adaptive_assignment')



cost_clusters=1+30*boundaires;

for i=1:n
    cost(i)= cost_clusters(lox(i,1), lox(i,2))+assign_delay;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cost=comm_cost(n, v, lox)
% n
% v
a=ones(v,v);
a(1:2,1:v)=30;
a(v-2:v,1:v)=30;
a(1:v,1:2)=30;
a(1:v,v-2:v)=30;
b=repmat(a,[n/v,n/v])

% whos b
figure(1)
aa=zeros(n,n);
for i=1:n
    aa(lox(i,1), lox(i,2))=1;
end
% whos aa
% aa
all=aa+b-1;
all=all>0.001;
imagesc(all)
axis off;
my_fig_trim_export('uniform_assignment')

% lox = randi([1,n],n,2);
cost=zeros(1,n);
for i=1:n
    cost(i)= b(lox(i,1), lox(i,2));
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function my_fig_trim_export(name)
% Cuts the unnecessary space around the given figure, names it with the
% name specified, and saves it in the directory (Results) in 4 different
% formats
% by: Mahmoud Nazzal
% date: 13-11-2018
set(gca,'FontSize',12, 'FontName', 'Times New Roman')  
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
saveas(fig, name)
saveas(fig,[name '.jpg'])
saveas(fig,[name '.pdf'])
% saveas(fig,[Dir '\' name '.eps'], 'epsc')
end
