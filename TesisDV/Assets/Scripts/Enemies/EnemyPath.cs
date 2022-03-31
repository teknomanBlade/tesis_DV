using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyPath : MonoBehaviour
{


    public Vector2[] nodes;




    private void OnDrawGizmos()
    {
        foreach (Vector2 vec in nodes)
        {
            Vector3 v3 = new Vector3(vec.x, 0f, vec.y);
            Gizmos.DrawWireSphere(v3, 0.2f);
        }
    }
}
