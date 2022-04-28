using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Node : MonoBehaviour
{
    public List<Node> neighbours = new List<Node>();

    public void OnDrawGizmos()
    {
        //Gizmos.DrawWireSphere(transform.position, 0.25f);
    }
}
