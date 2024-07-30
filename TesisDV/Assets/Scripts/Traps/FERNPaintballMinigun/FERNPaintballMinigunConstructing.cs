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
        /*GameObject aux = Instantiate(trapPrefab, transform.position, transform.rotation, parent.transform);
       
        if (GameVars.Values.currentShotsTrap2 > 0)
            aux.GetComponent<FERNPaintballMinigun>().shotsLeft = GameVars.Values.currentShotsTrap2;*/
        
        var aux = GameVars.Values.FERNPaintballMinigunPool.GetObject()
           .SetInitPos(transform.position)
           .SetInitRot(transform.rotation)
           .SetParent(parent.transform)
           .SetShotsRemainingZero();

        Destroy(aux.GetComponent<InventoryItem>());
        Destroy(gameObject);
    }
}
