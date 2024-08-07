using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathfindingManager : MonoBehaviour
{
    static public PathfindingManager Instance;

    public Node startingNode;
    public Node goalNode;
    // public Pathfinding _pf;
    private float debugTime = 1;
    private Vector2 closeNodes;
    private Node closestNode;
    //private bool first = true;
    public LayerMask obstacleMask;
    public List<Node> nodes = new List<Node>();

    void Start()
    {
        Instance = this;

        // _pf = new Pathfinding();
    }

    public void AddNodes(Node node)
    {
        nodes.Add(node);
        //Debug.Log("Node added");
    }

    public Node GetStartNode(Transform position) 
    {
        foreach(Node node in nodes)
        {   
            RaycastHit hit;        
            Vector3 dir = node.transform.position - position.transform.position;
            
            //RaycastHit2D hit = Physics2D.Raycast(position.transform.position, dir, dir.magnitude, obstacleMask);
            bool first = true;
            if(first)
            {
                //if(hit == true)
                if (Physics.Raycast(position.transform.position, dir, out hit, dir.magnitude, GameVars.Values.GetWallLayerMask()))
                {

                }
                else
                {
                    closeNodes = dir;
                    closestNode = node;
                    first = false;
                }
            }
            if(dir.magnitude < closeNodes.magnitude)
            {
                //if(hit == true)
                if (Physics.Raycast(position.transform.position, dir, out hit, dir.magnitude, GameVars.Values.GetWallLayerMask()))
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
        foreach(Node node in nodes)
        {           
            Vector3 dir = node.transform.position - position;

            bool first = true;
            if(first)
            {
                closeNodes = dir;
                closestNode = node;
                first = false;
            }
            if(dir.magnitude < closeNodes.magnitude)
            {
                closeNodes = dir;
                closestNode = node;
            }
        }

        //first = true;
        return closestNode; 
    }

    public Node GetClosestNode(Vector3 origin)
    {
        float distance = Vector3.Distance(nodes[0].transform.position, origin);//.position);
        int index = 0;

        for (int i = 1; i < nodes.Count; i++)
        {
            float aux = Vector3.Distance(nodes[i].transform.position, origin);//.position);
            if (aux < distance)
            {
                distance = aux;
                index = i;
            }
        }

        return nodes[index];
    }
}
