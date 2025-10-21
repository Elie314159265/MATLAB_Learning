ds = readmatrix('Jap-Math.xlsx');
histogram(ds(:,5),'FaceColor','w','LineWidth',1.5); hold on
histogram(ds(:,7),'FaceColor',[0.5 0.5 0.5]); hold on
xlabel('Score','FontSize',15)
ylabel('Number of Students','FontSize',15)
legend('Japanese','Mathematics','FontSize',15)
