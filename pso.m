%% 清空环境
clear
clc
%% 参数设置
w = 0.6;      % 惯性因子
c1 = 2;       % 加速常数
c2 = 2;       % 加速常数
%c1 = 2;       % 加速常数
%c2 = 2;       % 加速常数
Dim = 3;            % 维数
SwarmSize = 100;    % 粒子群规模
ObjFun = @PSO_PID;  % 待优化函数句柄
MaxIter = 100;      % 最大迭代次数  
MinFit = 0.01;       % 最小适应值 
Vmax = 1;
Vmin = -1;
Ub = [20 20 20];
Lb = [-10 -10 -10];

%% 粒子群初始化
    Range = ones(SwarmSize,1)*(Ub-Lb);                                              %产生随机向量
    Swarm = rand(SwarmSize,Dim).*Range + ones(SwarmSize,1)*Lb;      % 初始化粒子群位置
    VStep = rand(SwarmSize,Dim);                        % 初始化速度   维度
    fSwarm = zeros(SwarmSize,1);                                                         %适应度值的初始化  ：0
for i=1:SwarmSize
    i
    fSwarm(i,:) = feval(ObjFun,Swarm(i,:));                         % 粒子群的适应值
end

%% 个体极值和群体极值
[bestf,  bestindex]=min(fSwarm);
zbest=Swarm(bestindex,:);                                            % 全局最佳  ：位置
gbest=Swarm;                                                              % 个体最佳  ：个体最佳位置就是初始化位置
fgbest=fSwarm;                                                           % 个体最佳适应值        ：初始化适应度值
fzbest=bestf;                                                               % 全局最佳适应值         ：初始化中最优值

%% 迭代寻优
iter = 0;
y_fitness = zeros(1,MaxIter);   % 预先产生4个空矩阵

K_p = zeros(1,MaxIter);         
K_i = zeros(1,MaxIter);
K_d = zeros(1,MaxIter);
while( (iter < MaxIter) && (fzbest > MinFit) )
    for j=1:SwarmSize
        % 速度更新
        iter,j
        VStep(j,:) = w*VStep(j,:) + c1*rand*(gbest(j,:) - Swarm(j,:)) + c2*rand*(zbest - Swarm(j,:));
        if VStep(j,:)>Vmax, VStep(j,:)=Vmax; end
        if VStep(j,:)<Vmin, VStep(j,:)=Vmin; end
        % 位置更新
        Swarm(j,:)=Swarm(j,:)+VStep(j,:);
        for k=1:Dim
            if Swarm(j,k)>Ub(k), Swarm(j,k)=Ub(k); end
            if Swarm(j,k)<Lb(k), Swarm(j,k)=Lb(k); end
        end
        % 适应值
        fSwarm(j,:) = feval(ObjFun,Swarm(j,:));
        % 个体最优更新     
        if fSwarm(j) < fgbest(j)
            gbest(j,:) = Swarm(j,:);      %个体位置更新
            fgbest(j) = fSwarm(j);       %个体适应值更新
        end
        % 群体最优更新
        if fSwarm(j) < fzbest 
            zbest = Swarm(j,:);           %全体最优位置更新
            fzbest = fSwarm(j);          %全体最有适应值更新
        end
    end 
    iter = iter+1;                      % 迭代次数更新
    y_fitness(1,iter) = fzbest;         % 为绘图做准备
    K_p(1,iter) = zbest(1);
    K_i(1,iter) = zbest(2);
    K_d(1,iter) = zbest(3);
end
%% 绘图输出
figure(1)      % 绘制性能指标ITAE的变化曲线
plot(y_fitness,'LineWidth',2)
title('最优个体适应值','fontsize',18);
xlabel('迭代次数','fontsize',18);ylabel('适应值','fontsize',18);
set(gca,'Fontsize',18);

figure(2)      % 绘制PID控制器参数变化曲线
plot(K_p)
hold on
plot(K_i,'k','LineWidth',3)
plot(K_d,'--r')
title('Kp、Ki、Kd 优化曲线','fontsize',18);
xlabel('迭代次数','fontsize',18);ylabel('参数值','fontsize',18);
set(gca,'Fontsize',18);
legend('Kp','Ki','Kd');
