using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Node : MonoBehaviour
{
    [SerializeField] private PathfindingManager _pfManager; //Para testear uso el Serialize, despues que tome referencias.
    [SerializeField] private List<Node> _neighbours;
    private Vector2 closeNodes;
    private Node closestNode;
    public LayerMask obstacleMask;
    private bool first = true;
    public bool blocked;
    public int cost;

    private void Start()
    {
        _pfManager.AddNodes(this);
    }

    public List<Node> GetNeighbours(Node cn)
    {
        RaycastHit hit;
        List<Node> _neighbors = new List<Node>();

        foreach(Node node in _pfManager.nodes)
        {
            Vector3 dir = node.transform.position - cn.transform.position;
           
            //RaycastHit2D hit = Physics2D.Raycast(cn.transform.position, dir, dir.magnitude, obstacleMask);
            //if(hit == true)
            if (Physics.Raycast(cn.transform.position, dir, out hit, dir.magnitude, obstacleMask))//GameVars.Values.GetWallLayerMask()))
            {
                
            } 
            else
            {
                _neighbors.Add(node);
                //Debug.Log("soy " + this.gameObject +" este es mi vecino + " + node);
            }
        }
        return _neighbors;
        //return _neighbours;
    }
}
