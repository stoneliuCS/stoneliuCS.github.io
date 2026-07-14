#metadata((
  title: "number of connected components in undirected graph",
  date: "2026-07-13",
)) <post-meta>
#import "../../../lib/drawings.typ": draw-graph

#link("https://leetcode.com/problems/number-of-connected-components-in-an-undirected-graph/description/")[Problem] goes like this:

We have `n` nodes in our graph and a list of edges that represent a connection from `u` to `v`. We want to be able to return the number of connected components.

Pretty instantly I can recognize this as a #link("https://en.wikipedia.org/wiki/Disjoint-set_data_structure")[union find] problem. Why? Because we can initially start with every single node as their own component. Now as we add edges, we can union them so that they are reachable by their parents. For example if we have the following graph with $n = 4$. Then we can start with

#draw-graph((), nodes: ("0", "1", "2", "3"))

We can union each node together, say nodes $0$ and $1$ share an edge and $2$ and $3$ also share an edge.

#draw-graph((("0", "1"), ("2", "3")), nodes: ("0", "1", "2", "3"))

Clearly there should be $2$ connected components. If we allow $0$ and $3$ to be their respective representatives in each component then we clearly have $2$ components.

== Union Find Algorithm
The naive union find algorithm is as follows, initialize all the nodes in our graph to be their own representative:

```c
public:
  UnionFind(int n) {
    representatives = vector<int>(n);
    for (int i = 0; i < n; i++) {
      representatives[i] = i;
    }
  }
```
When we want to find the representative of a particular node in our graph we will recursively check if our current representative is the final one
```c
int find(int u) {
  if (representatives[u] != u) {
    return find(representatives[u]);
  } else {
    return u;
  }
}
```
Finally when we call our union algorithm we can find the representatives for each of our nodes and then set one's representative to the other.
```c
void unionNodes(int u, int v) {
  int parent_u = find(u);
  int parent_v = find(v);
  if (parent_u != parent_v) {
    representatives[parent_v] = parent_u;
  }
}
```
To get the number of connected components all we have to do is count the number of unique representatives we have in our union find data structure.
```c
int countComponents(int n, vector<vector<int>>& edges) {
  UnionFind uf = UnionFind(n);
  unordered_set<int> representatives;

  // Add each edge together
  for (const auto& edge: edges) {
    int u = edge[0];
    int v = edge[1];
    uf.unionNodes(u,v);
  }
  for (int i = 0; i < n; i++) {
    representatives.insert(uf.find(i));
  }
  return representatives.size();
}
```
