using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ThetaStar<T>
{
    public delegate bool Satisfies(T curr);
    public delegate Dictionary<T, float> GetNeighbours(T curr);
    public delegate float Heuristic(T curr);
    public delegate bool LOS(T curr, T last, Transform origin);

    public List<T> Run(T start, Satisfies satisfies, GetNeighbours getNeighbours, Heuristic heuristic, LOS los, Transform origin)
    {
        Dictionary<T, T> parentsDictionary = new Dictionary<T, T>();
        HashSet<T> visited = new HashSet<T>();
        PriorityQueue<T> pending = new PriorityQueue<T>();
        Dictionary<T, float> cost = new Dictionary<T, float>(); //Coste de nodo, el valor se determina con el coste actual + coste del parent.

        pending.Enqueue(start, 0);
        cost.Add(start, 0);

        while (!pending.IsEmpty)
        {
            T current = pending.Dequeue(); //Obtenemos el Nodo con el de menor coste).

            if (satisfies(current))
            {
                return SmoothPath(ConstructPath(current, parentsDictionary), los, origin);
                //return ConstructPath(current, parentsDictionary);
            }

            visited.Add(current);

            Dictionary<T, float> neighbours = getNeighbours(current);
            foreach (var item in neighbours)
            {
                T n = item.Key;
                if (visited.Contains(n)) continue;
                float nodeCost = item.Value;
                float totalCost = cost[current] + nodeCost;
                if (cost.ContainsKey(n) && cost[n] < totalCost) continue;
                parentsDictionary[n] = current;
                cost[n] = totalCost;
                pending.Enqueue(n, totalCost + heuristic(n));
            }
        }
        return new List<T>();
    }

    private List<T> ConstructPath(T end, Dictionary<T, T> parents)
    {
        //Creamos una lista vacia
        List<T> path = new List<T>();
        //Agregamos el final del camino.
        path.Add(end);

        //Agregamos los parents hasta que no haya una Key en el diccionario.
        while (parents.ContainsKey(path[path.Count - 1]))
        {
            path.Add(parents[path[path.Count - 1]]);
        }
        //Invertimos el orden de la coleccion y la devolvemos
        path.Reverse();
        return path;
    }

    private List<T> SmoothPath(List<T> path, LOS los, Transform origin)
    {
        if (path.Count <= 2) return path;

        List<T> smoothPath = new List<T>();

        int i = 1;
        T init = path[0];

        while (i <= path.Count)
        {
            if (i < path.Count && !los(init, path[i], origin))
            {
                smoothPath.Add(init);
                //smoothPath.Add(path[i - 1]);
                init = path[i - 1];
            }
            else if (i == path.Count)
            {
                smoothPath.Add(init);
                smoothPath.Add(path[i - 1]);
            }
            i++;
        }

        return smoothPath;
    }
}
