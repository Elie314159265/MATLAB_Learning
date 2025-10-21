%% 非線形計画法（Nonlinear Programming）による最適化
% 問題設定: 2つの製品（A, B）の価格を最適化して利益を最大化する
% 
% 【問題の概要】
% 製品の需要は価格に依存する（価格弾力性を考慮）
% 製品A: 需要 = 200 - 2*pA + 0.5*pB (価格が高いとB製品に流れる)
% 製品B: 需要 = 150 - 1.5*pB + 0.3*pA (価格が高いとA製品に流れる)
% 製造コスト: 製品A = 30円/個、製品B = 40円/個
% 制約: 生産能力、価格範囲、品質維持のための最低価格

clear; clc;

%% 1. 問題設定の可視化
fprintf('=== 非線形計画問題の設定 ===\n\n');
fprintf('【製品情報】\n');
fprintf('製品A:\n');
fprintf('  需要関数: qA = 200 - 2*pA + 0.5*pB\n');
fprintf('  製造コスト: 30 円/個\n');
fprintf('  制約: 30 ≤ pA ≤ 100 円\n\n');
fprintf('製品B:\n');
fprintf('  需要関数: qB = 150 - 1.5*pB + 0.3*pA\n');
fprintf('  製造コスト: 40 円/個\n');
fprintf('  制約: 40 ≤ pB ≤ 120 円\n\n');
fprintf('【制約条件】\n');
fprintf('  生産能力: qA + qB ≤ 250 個/日\n');
fprintf('  最低需要: qA ≥ 20, qB ≥ 15 個/日\n\n');

%% 2. 目的関数の定義
% 利益 = (価格 - コスト) × 需要
% Profit = (pA - 30)*(200 - 2*pA + 0.5*pB) + (pB - 40)*(150 - 1.5*pB + 0.3*pA)
% fminconは最小化問題なので、利益に-1を掛ける

objective = @(p) -((p(1) - 30) * (200 - 2*p(1) + 0.5*p(2)) + ...
                   (p(2) - 40) * (150 - 1.5*p(2) + 0.3*p(1)));

%% 3. 制約条件の定義

% 3-1. 非線形不等式制約: c(x) ≤ 0
% 制約1: qA + qB ≤ 250 (生産能力)
% 制約2: qA ≥ 20 → -qA + 20 ≤ 0
% 制約3: qB ≥ 15 → -qB + 15 ≤ 0
nonlcon = @(p) deal([
    (200 - 2*p(1) + 0.5*p(2)) + (150 - 1.5*p(2) + 0.3*p(1)) - 250;  % 生産能力
    -(200 - 2*p(1) + 0.5*p(2)) + 20;                                % 最低需要A
    -(150 - 1.5*p(2) + 0.3*p(1)) + 15                               % 最低需要B
], []);

% 3-2. 線形不等式制約: A*x ≤ b（今回は使用しない）
A = [];
b = [];

% 3-3. 線形等式制約: Aeq*x = beq（今回は使用しない）
Aeq = [];
beq = [];

% 3-4. 変数の範囲制約
% 下限: 製品Aは30円以上、製品Bは40円以上（コスト以上で販売）
lb = [30; 40];

% 上限: 製品Aは100円以下、製品Bは120円以下（市場価格の上限）
ub = [100; 120];

%% 4. 初期値の設定
% 初期価格: 製品A = 60円、製品B = 80円
p0 = [60; 80];

fprintf('【最適化問題の定式化】\n');
fprintf('目的関数（最大化）:\n');
fprintf('  Profit = (pA - 30)*(200 - 2*pA + 0.5*pB) + (pB - 40)*(150 - 1.5*pB + 0.3*pA)\n\n');
fprintf('制約条件:\n');
fprintf('  (200 - 2*pA + 0.5*pB) + (150 - 1.5*pB + 0.3*pA) ≤ 250  (生産能力)\n');
fprintf('  200 - 2*pA + 0.5*pB ≥ 20                               (最低需要A)\n');
fprintf('  150 - 1.5*pB + 0.3*pA ≥ 15                             (最低需要B)\n');
fprintf('  30 ≤ pA ≤ 100                                          (価格範囲A)\n');
fprintf('  40 ≤ pB ≤ 120                                          (価格範囲B)\n\n');
fprintf('初期価格: pA = %.0f円, pB = %.0f円\n\n', p0(1), p0(2));

%% 5. 最適化オプションの設定
options = optimoptions('fmincon', ...
    'Display', 'iter', ...              % 反復過程を表示
    'Algorithm', 'interior-point', ... % 内点法を使用
    'MaxIterations', 1000, ...         % 最大反復回数
    'OptimalityTolerance', 1e-6);      % 最適性の許容誤差

%% 6. 非線形計画問題を解く
fprintf('=== 最適化を実行中 ===\n');
[p_opt, fval, exitflag, output] = fmincon(objective, p0, A, b, Aeq, beq, ...
                                           lb, ub, nonlcon, options);

%% 7. 結果の計算
% 最適価格
pA_opt = p_opt(1);
pB_opt = p_opt(2);

% 最適需要量
qA_opt = 200 - 2*pA_opt + 0.5*pB_opt;
qB_opt = 150 - 1.5*pB_opt + 0.3*pA_opt;

% 最大利益
max_profit = -fval;

% 各製品の利益
profit_A = (pA_opt - 30) * qA_opt;
profit_B = (pB_opt - 40) * qB_opt;

%% 8. 結果の表示
fprintf('\n\n=== 最適化結果 ===\n\n');

% 収束状態の確認
if exitflag > 0
    fprintf('✓ 最適解が見つかりました（exitflag = %d）\n', exitflag);
    fprintf('  反復回数: %d 回\n\n', output.iterations);
else
    fprintf('✗ 警告: 最適解が見つかりませんでした（exitflag = %d）\n\n', exitflag);
end

% 最適価格
fprintf('【最適価格】\n');
fprintf('  製品A: %.2f 円\n', pA_opt);
fprintf('  製品B: %.2f 円\n\n', pB_opt);

% 需要量
fprintf('【予想需要量】\n');
fprintf('  製品A: %.2f 個/日\n', qA_opt);
fprintf('  製品B: %.2f 個/日\n', qB_opt);
fprintf('  合計:   %.2f 個/日\n\n', qA_opt + qB_opt);

% 利益
fprintf('【利益】\n');
fprintf('  製品A: %.2f 円/日\n', profit_A);
fprintf('  製品B: %.2f 円/日\n', profit_B);
fprintf('  合計:   %.2f 円/日\n\n', max_profit);

%% 9. 制約条件の確認
fprintf('【制約条件の確認】\n');
total_demand = qA_opt + qB_opt;
fprintf('  生産能力: %.2f / 250 個 (使用率: %.1f%%)\n', ...
    total_demand, (total_demand/250)*100);
fprintf('  製品Aの需要: %.2f ≥ 20 個 ✓\n', qA_opt);
fprintf('  製品Bの需要: %.2f ≥ 15 個 ✓\n\n', qB_opt);

%% 10. 初期値との比較
qA_init = 200 - 2*p0(1) + 0.5*p0(2);
qB_init = 150 - 1.5*p0(2) + 0.3*p0(1);
profit_init = (p0(1) - 30) * qA_init + (p0(2) - 40) * qB_init;

fprintf('【初期値との比較】\n');
fprintf('  初期価格:     pA = %.0f円, pB = %.0f円\n', p0(1), p0(2));
fprintf('  初期需要量:   qA = %.2f個, qB = %.2f個\n', qA_init, qB_init);
fprintf('  初期利益:     %.2f 円/日\n', profit_init);
fprintf('  利益改善率:   %.2f%%\n\n', ((max_profit - profit_init)/profit_init)*100);

%% 11. 結果の表形式表示
T = table({'製品A'; '製品B'; '合計'}, ...
    [pA_opt; pB_opt; NaN], ...
    [30; 40; NaN], ...
    [qA_opt; qB_opt; qA_opt+qB_opt], ...
    [profit_A; profit_B; max_profit], ...
    'VariableNames', {'製品名', '最適価格（円）', '製造コスト（円）', '需要量（個）', '利益（円/日）'});

fprintf('【結果サマリー】\n');
disp(T);

%% 12. 視覚化
figure('Name', '非線形計画法の可視化', 'Position', [100, 100, 1400, 500]);

% サブプロット1: 利益の等高線図と最適解
subplot(1, 3, 1);

pA_range = linspace(30, 100, 100);
pB_range = linspace(40, 120, 100);
[PA, PB] = meshgrid(pA_range, pB_range);

% 各価格での利益を計算
Profit = zeros(size(PA));
for i = 1:numel(PA)
    qA = 200 - 2*PA(i) + 0.5*PB(i);
    qB = 150 - 1.5*PB(i) + 0.3*PA(i);
    if qA >= 0 && qB >= 0  % 需要が正の場合のみ
        Profit(i) = (PA(i) - 30) * qA + (PB(i) - 40) * qB;
    else
        Profit(i) = NaN;
    end
end

contourf(PA, PB, Profit, 20, 'LineWidth', 0.5);
colorbar;
hold on;

% 初期値をプロット
plot(p0(1), p0(2), 'wo', 'MarkerSize', 12, 'MarkerFaceColor', 'white', ...
    'LineWidth', 2, 'DisplayName', sprintf('初期値 (%.0f, %.0f)', p0(1), p0(2)));

% 最適解をプロット
plot(pA_opt, pB_opt, 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'red', ...
    'LineWidth', 2, 'DisplayName', sprintf('最適解 (%.1f, %.1f)', pA_opt, pB_opt));

% 最適化の経路を矢印で表示
quiver(p0(1), p0(2), pA_opt-p0(1), pB_opt-p0(2), 0, ...
    'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);

xlabel('製品A の価格（円）');
ylabel('製品B の価格（円）');
title('利益の等高線図と最適解');
legend('Location', 'best');
grid on;
hold off;

% サブプロット2: 価格と需要の関係
subplot(1, 3, 2);

% 製品Aの価格変化に対する需要
pA_test = linspace(30, 100, 50);
qA_vs_pA = 200 - 2*pA_test + 0.5*pB_opt;
qB_vs_pA = 150 - 1.5*pB_opt + 0.3*pA_test;

yyaxis left
plot(pA_test, qA_vs_pA, 'b-', 'LineWidth', 2, 'DisplayName', '製品Aの需要');
hold on;
plot(pA_opt, qA_opt, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'red', ...
    'LineWidth', 2, 'DisplayName', '最適点（製品A）');
ylabel('製品A の需要（個）');
ylim([0, max(qA_vs_pA)*1.2]);

yyaxis right
plot(pA_test, qB_vs_pA, 'g--', 'LineWidth', 2, 'DisplayName', '製品Bの需要');
plot(pA_opt, qB_opt, 'mo', 'MarkerSize', 12, 'MarkerFaceColor', 'magenta', ...
    'LineWidth', 2, 'DisplayName', '最適点（製品B）');
ylabel('製品B の需要（個）');
ylim([0, max(qB_vs_pA)*1.2]);

xlabel('製品A の価格（円）');
title('価格変化と需要の関係');
legend('Location', 'best');
grid on;
hold off;

% サブプロット3: 利益の比較（棒グラフ）
subplot(1, 3, 3);

categories = {'製品A', '製品B', '合計'};
profit_data = [profit_A, profit_B, max_profit];

b = bar(profit_data);
b.FaceColor = 'flat';
b.CData(1,:) = [0.2, 0.6, 0.8];
b.CData(2,:) = [0.2, 0.8, 0.6];
b.CData(3,:) = [0.8, 0.2, 0.2];

set(gca, 'XTickLabel', categories);
ylabel('利益（円/日）');
title('製品別利益の内訳');
grid on;

% 利益の数値を棒の上に表示
text(1:length(profit_data), profit_data + max(profit_data)*0.05, ...
    arrayfun(@(x) sprintf('%.0f円', x), profit_data, 'UniformOutput', false), ...
    'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');

fprintf('\n可視化が完了しました。\n');
