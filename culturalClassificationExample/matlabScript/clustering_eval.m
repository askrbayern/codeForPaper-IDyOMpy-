function index = clustering_eval(Cc, Cb, Bc, Bch)
    Chinese_songs = [];
    Bach_songs = [];

    fn = fieldnames(Cc);
    for k=1:numel(fn)-1
        tmp = getfield(Cc, fn{k}); 
        tmp = mean(tmp(1,:));
        Chinese_songs(k, 1) = tmp;

        tmp = getfield(Cb, fn{k}); 
        tmp = mean(tmp(1,:));
        Chinese_songs(k, 2) = tmp;
    end
    
    fn = fieldnames(Bc);
    for k=1:numel(fn)-1
        tmp = getfield(Bc, fn{k});  
        tmp = mean(tmp(1,:));
        Bach_songs(k, 2) = tmp;

        tmp = getfield(Bch, fn{k}); 
        tmp = mean(tmp(1,:));
        Bach_songs(k, 1) = tmp;
    end

    a = [reshape(Bach_songs, [], 1); reshape(Chinese_songs, [], 1)];
    
    STD = std(a)
    M = mean(a) 
    
    Bach_songs = Bach_songs - M;
    Bach_songs = Bach_songs./STD;
    
    Chinese_songs = Chinese_songs - M;
    Chinese_songs = Chinese_songs./STD;
    

    figure; 

    scatter(Chinese_songs(:,1), Chinese_songs(:,2)); hold on; 
    scatter(Bach_songs(:,1), Bach_songs(:,2));
    plot([-100 100], [-100, 100]); 
    xlim([-4 6]);
    ylim([-4 6]);

    legend("Chinese Songs", "Bach Chorals")
    xlabel("Chinese Model (IC)")
    ylabel("Bach Model (IC)")
    title("Cultural Distance")

    inter_cultural_distance = 0; 
    count = 0;
    for i=1:size(Chinese_songs, 1)
       for j=1:size(Bach_songs, 1)
           X1 = Chinese_songs(i, :);
           X2 = Bach_songs(j,:);
           distance = sqrt(sum((X1 - X2).^2));
           inter_cultural_distance = inter_cultural_distance + distance;
           count = count + 1;
       end
    end
    inter_cultural_distance = inter_cultural_distance/count;

    intra_cultural_distance_A = 0; 
    count = 0;
    for i=1:size(Chinese_songs, 1)
        for j=1:size(Chinese_songs, 1)
           X1 = Chinese_songs(i, :);
           X2 = Chinese_songs(j,:);
           distance = sqrt(sum((X1 - X2).^2));
           intra_cultural_distance_A = intra_cultural_distance_A + distance;
           count = count + 1;
        end
    end
    intra_cultural_distance_A = intra_cultural_distance_A/count;


    intra_cultural_distance_B = 0; 
    count = 0;
    for i=1:size(Bach_songs, 1)
        for j=1:size(Bach_songs, 1)
           X1 = Bach_songs(i, :);
           X2 = Bach_songs(j,:);
           distance = sqrt(sum((X1 - X2).^2));
           intra_cultural_distance_B = intra_cultural_distance_B + distance;
           count = count + 1;
        end
    end
    intra_cultural_distance_B = intra_cultural_distance_B/count;

    disp("Inter Cultural Distance: "+ num2str(inter_cultural_distance));
    disp("Intra Cultural Distance on A: "+ num2str(intra_cultural_distance_A));
    disp("Intra Cultural Distance on B: "+ num2str(intra_cultural_distance_B));
    disp("Clustering Index: " + num2str(inter_cultural_distance/((intra_cultural_distance_A+intra_cultural_distance_B)/2)));
    index = inter_cultural_distance/((intra_cultural_distance_A+intra_cultural_distance_B)/2);
    % Clustering index similar to Dunn index
end

