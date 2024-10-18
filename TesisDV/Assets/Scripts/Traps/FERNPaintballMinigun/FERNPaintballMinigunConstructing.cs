using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FERNPaintballMinigunConstructing : MonoBehaviour
{
    public GameObject trapPrefab;
    Animator myAnimator;
    private GameObject parent;
    void Start()
    {
        myAnimator = GetComponent<Animator>();
        //parent = GameObject.Find("MainGame");
        parent = transform.parent.gameObject;
    }

    public void FinishAnim()
    {
        var aux = GameVars.Values.FERNPaintballMinigunPool.GetObject()
           .SetInitPos(transform.position)
           .SetInitRot(transform.rotation)
           .SetParent(parent.transform)
           .SetShotsRemainingZero();

        Destroy(aux.GetComponent<InventoryItem>());
        Destroy(gameObject);
    }
}
