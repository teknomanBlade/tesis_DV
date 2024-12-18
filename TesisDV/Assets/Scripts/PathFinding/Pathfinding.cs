using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pathfinding
{
    public List<Node> ConstructPathThetaStar(Node startingNode, Node goalNode)
    {
        List<Node> path = ConstructPathAStar(startingNode, goalNode);
        if (path.Count == 0) return path;

        int index = 0;
        while (index <= path.Count - 1)
        {
            int grandParent = index + 2;
            if (grandParent > path.Count - 1) break;

            if (InSight(path[index].transform.position, path[grandParent].transform.position))
                path.Remove(path[index + 1]);
            else
                index++;
        }

        return path;
    }

    bool InSight(Vector3 start, Vector3 end)
    {
        if (!Physics.Raycast(start, end - start, Vector3.Distance(start, end), GameVars.Values.GetAllWallsLayerMasks())) return true;
        else return false;
    }


    public List<Node> ConstructPathAStar(Node startingNode, Node goalNode)
    {
        PriorityQueue frontier = new PriorityQueue();
        frontier.Put(startingNode, 0);
        Dictionary<Node, Node> cameFrom = new Dictionary<Node, Node>();
        Dictionary<Node, int> costSoFar = new Dictionary<Node, int>();
        cameFrom.Add(startingNode, null);
        costSoFar.Add(startingNode, 0);

        while (frontier.Count() > 0)
        {
            Node current = frontier.Get();

            if (current == goalNode)
            {
                List<Node> path = new List<Node>();
                Node nodeToAdd = current;
                while (nodeToAdd != null)
                {
                    path.Add(nodeToAdd);
                    nodeToAdd = cameFrom[nodeToAdd];
                }
                //path.Reverse();
                return path;
            }

            foreach (Node next in current.GetNeighbours(current))
            {
                if (next.blocked) continue;
                int newCost = costSoFar[current] + next.cost;
                if (!costSoFar.ContainsKey(next) || newCost < costSoFar[next])
                {
                    if (costSoFar.ContainsKey(next))
                    {
                        costSoFar[next] = newCost;
                        cameFrom[next] = current;
                    }
                    else
                    {
                        cameFrom.Add(next, current);
                        costSoFar.Add(next, newCost);
                    }
                    float priority = newCost + Heuristic(next.transform.position, goalNode.transform.position);
                    frontier.Put(next, priority);

                }
            }
        }
        return default;
    }

    public float Heuristic(Vector3 a, Vector3 b)
    {
        return Vector3.Distance(a, b);
    }

}

/* using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pathfinding
{
    public LayerMask obstacleMask;

    public List<Node> ConstructPathThetaStar(Node startingNode, Node goalNode)
    {
        List<Node> path = ConstructPathAStar(startingNode, goalNode);
        if(path.Count == 0) return path;

        int index = 0;

        while(index <= path.Count - 1)
        {
            int pastTwoIndex = index + 2;

            if(pastTwoIndex > path.Count - 1)
            {
                Debug.Log("mala suerte.");
                break;
            }     

            if (InSight(path[index].transform.position, path[pastTwoIndex].transform.position))
            {
                path.Remove(path[index + 1]);
            }

            else
            {
                index++;
            }

            return path;
        }

        return default;
    }

    bool InSight(Vector3 start, Vector3 end)
    {
        //Vector3 dir = end - start;
        if(!Physics.Raycast(start, end - start, Vector3.Distance(start,end), obstacleMask))
        {
            Debug.Log("captain pierce was a strong man");
            return true;
        }
        else
        {
            return false; 
        }
    }

    public List<Node> ConstructPathAStar(Node startingNode, Node goalNode)
    {
        PriorityQueue frontier = new PriorityQueue();
        frontier.Put(startingNode, 0);
        Dictionary<Node, Node> cameFrom = new Dictionary<Node, Node>();
        Dictionary<Node, int> costSoFar = new Dictionary<Node, int>();
        cameFrom.Add(startingNode, null);
        costSoFar.Add(startingNode, 0);


        while (frontier.Count() > 0)
        {
            Node current = frontier.Get();

            if (current == goalNode)
            {
                List<Node> path = new List<Node>();
                Node nodeToAdd = current;
                while (nodeToAdd != null)
                {
                    path.Add(nodeToAdd);
                    nodeToAdd = cameFrom[nodeToAdd];
                }
                return path;
            }

            foreach (Node next in current.GetNeighbours(current)) //Antes usaba starting node
            {
                int newCost = costSoFar[current] + next.cost;
                if (!costSoFar.ContainsKey(next) || newCost < costSoFar[next])
                {
                    if (costSoFar.ContainsKey(next))
                    {
                        costSoFar[next] = newCost;
                        cameFrom[next] = current;
                    }
                    else
                    {
                        cameFrom.Add(next, current);
                        costSoFar.Add(next, newCost);
                    }
                    float priority = newCost + Heuristic(next.transform.position, goalNode.transform.position);
                    frontier.Put(next, priority);

                }
            }
        }
        return default; 
    }
    
    float Heuristic(Vector3 a, Vector3 b)
    {
        return Vector3.Distance(a, b);
    }
}

 */