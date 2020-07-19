using LightGraphs, GraphIO
using StatsBase

function label_partition(g; k=8)
    unlabeled_nodes = Set(vertices(g));
    labeled_nodes = Set();
    finished_nodes = Set();
    labels = zeros(Int, nv(g));
    random_k_nodes = sample(vertices(g), k, replace=false);
    for (i, r) in enumerate(random_k_nodes)
        labels[r] = i;
        unlabeled_nodes = delete!(unlabeled_nodes, r)
        labeled_nodes = push!(labeled_nodes, r)
    end

    operations = 0
    while !isempty(unlabeled_nodes)
        for n in copy(labeled_nodes)
            n_neighbors = setdiff(Set(neighbors(g, n)), union(labeled_nodes, finished_nodes))
            operations += 1
            if !isempty(n_neighbors)
                neighbor = sample(collect(n_neighbors), 1)[1];
                labels[neighbor] = labels[n];
                unlabeled_nodes = delete!(unlabeled_nodes, neighbor);
                labeled_nodes = push!(labeled_nodes, neighbor);
                n_neighbors = delete!(n_neighbors, neighbor);
            end
            if isempty(n_neighbors)
                labeled_nodes = delete!(labeled_nodes, n);
                finished_nodes = push!(finished_nodes, n);
            end
        end
    end
    return labels
end

function graph_partition(g; k=8, c=10)
    best_partition = []
    best_modularity = -Inf
    for i in 1:c
        partitions = label_partition(g; k=k)
        partition_modularity = modularity(g, partitions)
#     println(partition_modularity)
        if (best_modularity < partition_modularity)
            best_partition = partitions
            best_modularity = partition_modularity
        end
    end
    return best_partition, best_modularity
end
