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
        RaycastHit itemHit;
        List<Node> _neighbors = new List<Node>();

        foreach(Node node in _pfManager.nodes)
        {
            Vector3 dir = node.transform.position - cn.transform.position;
            Vector3 raycastAux = new Vector3(cn.transform.position.x, 1f , cn.transform.position.z);

            //RaycastHit2D hit = Physics2D.Raycast(cn.transform.position, dir, dir.magnitude, obstacleMask);
            //if(hit == true)
            if (Physics.Raycast(cn.transform.position, dir, out hit, dir.magnitude, obstacleMask))//GameVars.Values.GetWallLayerMask()))
            {
                
            } 
            else if (Physics.Raycast(raycastAux, dir, out itemHit, dir.magnitude, GameVars.Values.GetItemLayerMask()))
            {
                if(itemHit.collider.GetComponent<Door>())
                {
                    Debug.Log("Soy una puerta "+ itemHit.collider.gameObject);
                    if(itemHit.collider.GetComponent<Door>().IsLockedToGrays)
                    {
                        Debug.Log("Estoy cerrada " + itemHit.collider.gameObject.name + itemHit.collider.GetComponent<Door>().IsLocked + ("soy " + this.gameObject.name + ("mi vecino es " + node.gameObject.name)));
                    }
                    else
                    {
                        Debug.Log("Estoy abierta " + itemHit.collider.gameObject.name + itemHit.collider.GetComponent<Door>().IsLocked + ("soy " + this.gameObject.name + ("mi vecino es " + node.gameObject.name)));
                        if(node != cn && Vector3.Distance(cn.transform.position, node.transform.position) <= 20)
                        {
                            _neighbors.Add(node);
                        }
                        
                    }
                }
                //_neighbors.Add(node);
                //Debug.Log("soy " + this.gameObject +" este es mi vecino + " + node);
            }
            else
            {
                if(node != cn && Vector3.Distance(cn.transform.position, node.transform.position) <= 20)
                {
                    _neighbors.Add(node);
                }
                Debug.Log("soy " + this.gameObject.name + "y agregue a " + node.gameObject.name);
            }
        }
        return _neighbors;
        //return _neighbours;
    }
}
