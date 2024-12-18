using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathfindingManager : MonoBehaviour
{
    static public PathfindingManager Instance;

    public Node startingNode;
    public Node goalNode;
    public Pathfinding _pf;
    private float debugTime = 1;
    private Vector2 closeNodes;
    private Node closestNode;
    //private bool first = true;
    public LayerMask wallMask;
    public LayerMask obstacleMask;
    public List<Node> nodes = new List<Node>();

    void Awake()
    {
        Instance = this;

        _pf = new Pathfinding();
    }

    public void AddNodes(Node node)
    {
        nodes.Add(node);
    }

    public Node GetStartNode(Transform position)
    {
        foreach (Node node in nodes)
        {
            RaycastHit hit;
            Vector3 dir = node.transform.position - position.transform.position;

            bool first = true;
            if (first)
            {
                if (Physics.Raycast(position.transform.position, dir, out hit, dir.magnitude, obstacleMask))
                {

                }
                else
                {
                    closeNodes = dir;
                    closestNode = node;
                    first = false;
                }
            }
            if (dir.magnitude < closeNodes.magnitude)
            {
                if (Physics.Raycast(position.transform.position, dir, out hit, dir.magnitude, obstacleMask))
                {

                }
                else
                {
                    closeNodes = dir;
                    closestNode = node;
                }
            }
        }

        return closestNode;
    }

    public Node GetEndNode(Vector3 position)
    {
        Debug.Log("Es el primero");
        bool first = true;
        foreach (Node node in nodes)
        {
            Vector3 dir = node.transform.position - position;

            if (first)
            {
                closeNodes = dir;
                closestNode = node;
                first = false;
            }
            if (dir.magnitude < closeNodes.magnitude)
            {
                closeNodes = dir;
                closestNode = node;
            }
        }

        return closestNode;
    }

    public Node GetClosestNode(Vector3 origin)
    {
        float distance = Vector3.Distance(nodes[0].transform.position, origin);
        int index = 0;

        for (int i = 1; i < nodes.Count; i++)
        {
            float aux = Vector3.Distance(nodes[i].transform.position, origin);
            if (aux < distance)
            {
                distance = aux;
                index = i;
            }
        }

        return nodes[index];
    }

    public Node GetNearestCoverNode(Vector3 enemyPosition)
    {
        List<Node> coverNodes = new List<Node>();

        for (int i = 1; i < nodes.Count; i++)
        {
            Vector3 dir = enemyPosition - nodes[i].transform.position;
            if (Physics.Raycast(nodes[i].transform.position, dir, out RaycastHit hit, dir.magnitude, wallMask))
            {
                coverNodes.Add(nodes[i]);
            }
        }

        Node coverNode = coverNodes[0];
        float distance = 999; //Devuelve el nodo para esconderse mas cercano.
        for (int i = 1; i < coverNodes.Count; i++)
        {
            if (Vector3.Distance(coverNodes[i].transform.position, enemyPosition) < distance)
            {
                distance = Vector3.Distance(coverNodes[i].transform.position, enemyPosition);
                coverNode = coverNodes[i];
            }

        }
        return coverNode;
    }

    public Node GetFarthestCoverNode(Vector3 enemyPosition, Vector3 soldierPosition)
    {
        List<Node> coverNodes = new List<Node>();

        for (int i = 1; i < nodes.Count; i++)
        {
            Vector3 dir = enemyPosition - nodes[i].transform.position;
            if (Physics.Raycast(nodes[i].transform.position, dir, out RaycastHit hit, dir.magnitude, wallMask))
            {
                coverNodes.Add(nodes[i]);
            }
        }

        Node coverNode = coverNodes[0];

        float distance = 999; //Devuelve el nodo para esconderse mas cercano al soldado que pidió la función.
        for (int i = 1; i < coverNodes.Count; i++)
        {
            if (Vector3.Distance(coverNodes[i].transform.position, soldierPosition) < distance)
            {
                distance = Vector3.Distance(coverNodes[i].transform.position, soldierPosition);
                coverNode = coverNodes[i];
            }
        }
        return coverNode;
    }

}
