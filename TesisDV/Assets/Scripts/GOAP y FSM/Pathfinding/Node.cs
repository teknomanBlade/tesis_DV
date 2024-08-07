using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class Node : MonoBehaviour
{
    [SerializeField] private PathfindingManager _pfManager;
    public int heuristic;
    public Node[] neighbours;
    public float searchRadius = 100f;
    public LayerMask nodeLayer;

    void Awake()
    {
        _pfManager.AddNodes(this);

        // neighbours = Physics.OverlapSphere(transform.position, searchRadius, nodeLayer)
        //                     .Where(x => x.GetComponent<Node>() != null)
        //                     .Select(x => x.GetComponent<Node>())
        //                     .Where(x => x != this)
        //                     .ToArray();

                            
    }

    public IEnumerable<WeightedNode<Node>> GetNeighbours()
    {
        return neighbours.Select(n => new WeightedNode<Node>(n, Vector3.Distance(transform.position, n.transform.position)));
    }

    public float GetHeuristic(Node target)
    {
        return 1;
        // return Vector3.Distance(transform.position, target.transform.position);
    }
}
