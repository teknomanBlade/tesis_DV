using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathfindingManager : MonoBehaviour
{
    public Node startingNode;
    public Node goalNode;
    public Pathfinding _pf;
    private float debugTime = 1;
    private Vector2 closeNodes;
    private Node closestNode;
    private bool first = true;
    public LayerMask obstacleMask;
    public List<Node> nodes = new List<Node>();

    void Start()
    {
        _pf = new Pathfinding();
    }

    public void AddNodes(Node node)
    {
        nodes.Add(node);
        Debug.Log("Node added");
    }

    public Node GetStartNode(Transform position) 
    {
        foreach(Node node in nodes)
        {   
            RaycastHit hit;        
            Vector3 dir = node.transform.position - position.transform.position;
            
            //RaycastHit2D hit = Physics2D.Raycast(position.transform.position, dir, dir.magnitude, obstacleMask);

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

        first = true;
        return closestNode; 

        //Version vieja en 2D

        /* foreach(Node node in nodes)  
        {           
            Vector2 dir = node.transform.position - position.transform.position;
            
            RaycastHit2D hit = Physics2D.Raycast(position.transform.position, dir, dir.magnitude, obstacleMask);

            if(first)
            {
                if(hit == true)
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
                if(hit == true)
                {

                }
                else
                {
                    closeNodes = dir;
                    closestNode = node;
                }       
            }
        }

        first = true;
        return closestNode;  */
    }

    public Node GetEndNode(Transform position) 
    {
        foreach(Node node in nodes)
        {           
            Vector3 dir = node.transform.position - position.transform.position;


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

        first = true;
        return closestNode; 
    }
}

//No se si borrarlo o no, por las dudas lo dejo.

/* using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PathfindingManager : MonoBehaviour
{
    private static PathfindingManager _pathfindingManager;
    public static PathfindingManager Instance { get { return _pathfindingManager; } }

    public LayerMask obstacleLayer;

    public List<Node> allNodes = new List<Node>();

    public Node end;

    public ThetaStar<Node> thetastar = new ThetaStar<Node>();

    public float gizmosRadius;

    private void Awake()
    {
        if (_pathfindingManager == null) _pathfindingManager = this;
        else Destroy(this);

        if (allNodes.Count < 1) GetAllNodesInScene();
    }

    private void Update()
    {
        if (allNodes.Count < 1) GetAllNodesInScene();
    }

    public void GetAllNodesInScene()
    {
        allNodes.Clear();
        Node[] nodeArray = FindObjectsOfType<Node>();
        foreach (Node point in nodeArray)
        {
            allNodes.Add(point);
        }

        foreach (Node node in allNodes)
        {
            node.neighbours.Clear();
            foreach (Node node2 in allNodes)
            {
                if (Vector3.Distance(node.transform.position, node2.transform.position) < 1.9f && !node2.Equals(node))
                {
                    node.neighbours.Add(node2);
                }
            }
        }
    }

    public List<Node> GetPath(Transform origin, Vector3 destination)
    {
        List<Node> path = new List<Node>();
        Node start = GetClosestNode(origin);
        end = GetClosestNode(destination);

        path = thetastar.Run(start, Satisfies, GetNeighboursWithCost, Heuristic, LOS, origin);

        return path;
    }

    private Node GetClosestNode(Transform origin)
    {
        float distance = Vector3.Distance(allNodes[0].transform.position, origin.position);
        int index = 0;

        for (int i = 1; i < allNodes.Count; i++)
        {
            float aux = Vector3.Distance(allNodes[i].transform.position, origin.position);
            if (aux < distance)
            {
                distance = aux;
                index = i;
            }
        }

        return allNodes[index];
    }

    private Node GetClosestNode(Vector3 origin)
    {
        float distance = Vector3.Distance(allNodes[0].transform.position, origin);
        int index = 0;

        for (int i = 1; i < allNodes.Count; i++)
        {
            float aux = Vector3.Distance(allNodes[i].transform.position, origin);
            if (aux < distance)
            {
                distance = aux;
                index = i;
            }
        }

        return allNodes[index];
    }

    public List<Node> GetNeighbours(Node n)
    {
        List<Node> neighbours = new List<Node>();

        for (int i = 0; i < n.neighbours.Count; i++)
        {
            if (n.neighbours[i] != null) neighbours.Add(n.neighbours[i]);
        }

        return neighbours;
    }

    public Dictionary<Node, float> GetNeighboursWithCost(Node n)
    {
        Dictionary<Node, float> neighboursDictionary = new Dictionary<Node, float>();
        List<Node> neighbours = GetNeighbours(n);
        foreach (var item in neighbours)
        {
            float cost = Vector3.Distance(n.transform.position, item.transform.position);
            neighboursDictionary.Add(item, cost);
        }
        return neighboursDictionary;
    }

    public float Heuristic(Node n)
    {
        float h = Vector3.Distance(n.transform.position, end.transform.position);

        int layer = 10; // Set to intended layer
        int layermask = 1 << layer; // Then bit shift an int set to 1 by layer

        Collider[] aux = Physics.OverlapSphere(n.transform.position, 0.75f, layermask);
        if (aux.Length > 0) h += 9999;
        return h;
    }

    public bool Satisfies(Node x)
    {
        if (x == end) return true;
        else return false;
    }

    public bool LOS(Node a, Node b, Transform origin)
    {
        Vector3 start = a.transform.position;
        Vector3 direction = (b.transform.position - a.transform.position);
        float distance = Vector3.Distance(a.transform.position, b.transform.position);
        float extents = origin.gameObject.GetComponent<Collider>().bounds.extents.magnitude * 0.75f;

        bool initialPass = LOSRaycast(a.transform.position, direction, distance);
        if (initialPass)
        {
            Vector3 rightSide = Vector3.Cross(direction, Vector3.up).normalized * -extents;
            Debug.DrawRay(start, rightSide, Color.red);
            bool rightSidePass = LOSRaycast(start + rightSide, direction, distance);
            if (rightSidePass)
            {
                Vector3 leftSide = Vector3.Cross(direction, Vector3.up).normalized * extents;
                Debug.DrawRay(start, leftSide, Color.red);
                bool leftSidePass = LOSRaycast(start + leftSide, direction, distance);
                if (leftSidePass) return true;
            }
        }
        return false;
    }

    private bool LOSRaycast(Vector3 start, Vector3 direction, float distance)
    {  
        int layer = 10;
        int layermask = 1 << layer;

        RaycastHit hit;
        bool result = Physics.Raycast(start, direction, out hit, distance, layermask);
        if (result && hit.collider.gameObject.layer == 10)
        {
            Debug.DrawRay(start, direction, Color.red);
            return false;
        }
        else return true;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.blue;
        if (end != null) Gizmos.DrawSphere(end.transform.position, gizmosRadius);
    }

} */