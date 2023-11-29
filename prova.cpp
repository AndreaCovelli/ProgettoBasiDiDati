
#include <iostream>
#include <vector>
#include <queue>
#include <climits>

using namespace std;

const int INF = INT_MAX;

// Function to find the minimum cut using Gomory Cut algorithm
int gomoryCut(vector<vector<int>>& graph, int source, int sink) {
    int n = graph.size();
    vector<int> parent(n);
    vector<int> minCut(n);
    vector<vector<int>> residualGraph(n, vector<int>(n));

    // Initialize residual graph with the original capacities
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            residualGraph[i][j] = graph[i][j];
        }
    }

    // Run Ford-Fulkerson algorithm to find the maximum flow
    while (true) {
        vector<bool> visited(n, false);
        vector<int> minCapacity(n, INF);
        queue<int> q;

        q.push(source);
        visited[source] = true;
        minCapacity[source] = INF;

        // BFS to find augmenting path
        while (!q.empty()) {
            int u = q.front();
            q.pop();

            for (int v = 0; v < n; v++) {
                if (!visited[v] && residualGraph[u][v] > 0) {
                    q.push(v);
                    visited[v] = true;
                    parent[v] = u;
                    minCapacity[v] = min(minCapacity[u], residualGraph[u][v]);
                }
            }
        }

        // If no augmenting path is found, break the loop
        if (!visited[sink]) {
            break;
        }

        // Update the residual capacities and reverse edges along the path
        for (int v = sink; v != source; v = parent[v]) {
            int u = parent[v];
            residualGraph[u][v] -= minCapacity[sink];
            residualGraph[v][u] += minCapacity[sink];
        }
    }

    // Find the minimum cut by running DFS from the source
    vector<bool> visited(n, false);
    queue<int> q;
    q.push(source);
    visited[source] = true;

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        for (int v = 0; v < n; v++) {
            if (!visited[v] && residualGraph[u][v] > 0) {
                q.push(v);
                visited[v] = true;
            }
        }
    }

    // Store the minimum cut edges
    for (int i = 0; i < n; i++) {
        if (visited[i]) {
            for (int j = 0; j < n; j++) {
                if (!visited[j] && graph[i][j] > 0) {
                    minCut.push_back(graph[i][j]);
                }
            }
        }
    }

    // Return the minimum cut value
    return minCut.size();
}

int main() {
    // Example usage
    vector<vector<int>> graph = {
        {0, 16, 13, 0, 0, 0},
        {0, 0, 10, 12, 0, 0},
        {0, 4, 0, 0, 14, 0},
        {0, 0, 9, 0, 0, 20},
        {0, 0, 0, 7, 0, 4},
        {0, 0, 0, 0, 0, 0}
    };

    int source = 0;
    int sink = 5;

    int minCut = gomoryCut(graph, source, sink);

    cout << "Minimum cut value: " << minCut << endl;

    return 0;
}
