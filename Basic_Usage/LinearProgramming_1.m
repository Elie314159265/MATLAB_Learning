%% 線形計画法（Linear Programming）による最適化
% 問題設定: 2つの製品（A, B）の生産量を最適化して利益を最大化する
% 
% 【問題の概要】
% 製品A: 加工時間2時間、組立時間1時間、検査時間4時間、利益3,000円
% 製品B: 加工時間3時間、組立時間1時間、検査時間5時間、利益4,000円
% 制約: 加工120時間、組立50時間、検査80時間まで利用可能

clear; clc;

%% 1. 問題設定の可視化
fprintf('=== 線形計画問題の設定 ===\n\n');
fprintf('【製品情報】\n');
fprintf('           製品A   製品B   利用可能時間\n');
fprintf('加工時間:    2       3       120 時間\n');
fprintf('組立時間:    1       1        50 時間\n');
fprintf('検査時間:    4       5        80 時間\n');
fprintf('利益:     3,000   4,000     （最大化）\n\n');

%% 2. 制約条件の定義（不等式制約）
% Ax ≤ b の形式で制約条件を定義
% x = [製品Aの生産量; 製品Bの生産量]

% 制約行列 A（各行が1つの制約条件を表す）
A = [2  3;   % 第1行: 2*xA + 3*xB ≤ 120 (加工時間の制約)
     1  1;   % 第2行: 1*xA + 1*xB ≤  50 (組立時間の制約)
     4  5];  % 第3行: 4*xA + 5*xB ≤  80 (検査時間の制約)

% 制約の右辺ベクトル b（リソースの上限）
b = [120;   % 加工時間の上限
     50;    % 組立時間の上限
     80];   % 検査時間の上限

%% 3. 等式制約の定義
% Aeq*x = beq の形式（今回は等式制約なし）
Aeq = [];
beq = [];

%% 4. 変数の範囲制約
% 下限: 生産量は0以上（負の生産量はあり得ない）
lb = [0; 0];

% 上限: 特に指定なし（デフォルトで無限大）
ub = [];

%% 5. 目的関数の定義
% 目的: 利益を最大化
% 利益 = 3000*xA + 4000*xB

% linprogは最小化問題を解くため、係数に-1を掛ける
% minimize: -3000*xA - 4000*xB
% ⇔ maximize:  3000*xA + 4000*xB
f = [-3000, -4000];

fprintf('【最適化問題の定式化】\n');
fprintf('目的関数（最大化）: 3000*xA + 4000*xB\n');
fprintf('制約条件:\n');
fprintf('  2*xA + 3*xB ≤ 120  (加工時間)\n');
fprintf('  1*xA + 1*xB ≤  50  (組立時間)\n');
fprintf('  4*xA + 5*xB ≤  80  (検査時間)\n');
fprintf('  xA, xB ≥ 0         (非負制約)\n\n');

%% 6. 線形計画問題を解く
% linprog(f, A, b, Aeq, beq, lb, ub, options)
options = optimoptions('linprog', 'Display', 'off'); % 詳細表示をオフ
[x, fval, exitflag, output] = linprog(f, A, b, Aeq, beq, lb, ub, options);

%% 7. 結果の表示
fprintf('=== 最適化結果 ===\n\n');

% 収束状態の確認
if exitflag == 1
    fprintf('✓ 最適解が見つかりました\n\n');
else
    fprintf('✗ 警告: 最適解が見つかりませんでした（exitflag = %d）\n\n', exitflag);
end

% 最適生産量
fprintf('【最適な生産量】\n');
fprintf('  製品A: %.2f 個\n', x(1));
fprintf('  製品B: %.2f 個\n\n', x(2));

% 最大利益
max_profit = -fval; % 符号を戻して最大利益を計算
fprintf('【最大利益】\n');
fprintf('  %.0f 円\n\n', max_profit);

%% 8. 制約条件の使用状況を確認
fprintf('【リソースの使用状況】\n');

% 実際に使用したリソース量を計算
used_resources = A * x;

resource_names = {'加工時間', '組立時間', '検査時間'};
for i = 1:length(b)
    usage_rate = (used_resources(i) / b(i)) * 100;
    slack = b(i) - used_resources(i); % スラック変数（余裕）
    
    fprintf('  %s: %.2f / %.2f 時間 (使用率: %.1f%%, 余裕: %.2f 時間)', ...
        resource_names{i}, used_resources(i), b(i), usage_rate, slack);
    
    if slack < 0.01
        fprintf(' ← ボトルネック！\n');
    else
        fprintf('\n');
    end
end

%% 9. 結果の表形式表示
fprintf('\n【結果サマリー】\n');
T = table({'製品A'; '製品B'}, x, [3000; 4000], x .* [3000; 4000], ...
    'VariableNames', {'製品名', '生産量', '単価（円）', '利益（円）'});
disp(T);
fprintf('合計利益: %.0f 円\n\n', max_profit);

%% 10. 視覚化
figure('Name', '線形計画法の可視化', 'Position', [100, 100, 1000, 500]);

% サブプロット1: 実行可能領域と最適解
subplot(1, 2, 1);

% 制約条件の境界線を描画
xA_range = linspace(0, 70, 1000);

% 各制約条件の境界線
constraint1 = (120 - 2*xA_range) / 3;  % 加工時間
constraint2 = 50 - xA_range;           % 組立時間
constraint3 = (80 - 4*xA_range) / 5;   % 検査時間

plot(xA_range, constraint1, 'r-', 'LineWidth', 1.5, 'DisplayName', '加工時間制約');
hold on;
plot(xA_range, constraint2, 'g-', 'LineWidth', 1.5, 'DisplayName', '組立時間制約');
plot(xA_range, constraint3, 'b-', 'LineWidth', 1.5, 'DisplayName', '検査時間制約');

% 実行可能領域を塗りつぶす
xA_feasible = [0, 0, x(1), 20, 0];
xB_feasible = [0, 16, x(2), 0, 0];
fill(xA_feasible, xB_feasible, [0.9, 0.9, 0.9], ...
    'FaceAlpha', 0.5, 'DisplayName', '実行可能領域');

% 等利益線（複数）
profit_levels = [40000, 80000, max_profit];
for profit = profit_levels
    iso_profit = (profit - (-f(1))*xA_range) / (-f(2));
    if profit == max_profit
        plot(xA_range, iso_profit, 'k--', 'LineWidth', 2, ...
            'DisplayName', sprintf('最大利益線: %.0f円', profit));
    else
        plot(xA_range, iso_profit, 'k:', 'LineWidth', 1, ...
            'DisplayName', sprintf('利益線: %.0f円', profit));
    end
end

% 最適解をプロット
plot(x(1), x(2), 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'red', ...
    'LineWidth', 2, 'DisplayName', sprintf('最適解 (%.1f, %.1f)', x(1), x(2)));

xlabel('製品A の生産量');
ylabel('製品B の生産量');
title('実行可能領域と最適解');
legend('Location', 'best');
grid on;
xlim([0, 70]);
ylim([0, 50]);
hold off;

% サブプロット2: リソース使用率の棒グラフ
subplot(1, 2, 2);

usage_rates = (used_resources ./ b) * 100;
bar_colors = [0.2, 0.6, 0.8; 0.2, 0.8, 0.6; 0.8, 0.6, 0.2];

b_chart = bar(usage_rates);
b_chart.FaceColor = 'flat';
b_chart.CData = bar_colors;

hold on;
yline(100, 'r--', 'LineWidth', 2, 'DisplayName', '100%（上限）');
hold off;

set(gca, 'XTickLabel', resource_names);
ylabel('使用率 (%)');
title('リソース使用率');
ylim([0, 110]);
grid on;

% 使用率の数値を棒の上に表示
text(1:length(usage_rates), usage_rates + 3, ...
    arrayfun(@(x) sprintf('%.1f%%', x), usage_rates, 'UniformOutput', false), ...
    'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');

fprintf('可視化が完了しました。\n');
