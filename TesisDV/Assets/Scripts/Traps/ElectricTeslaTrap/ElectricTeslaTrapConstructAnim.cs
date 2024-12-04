using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElectricTeslaTrapConstructAnim : MonoBehaviour, ITrapBuildable
{
    public Animator myAnimator;
    public GameObject parent;

    // Start is called before the first frame update
    void Start()
    {
        myAnimator = GetComponent<Animator>();
        parent = transform.parent.gameObject;
    }

    public void FinishAnim()
    {
        var electricTeslaTrap = GameVars.Values.TeslaElectricTrapPool.GetObject()
            .SetInitPos(transform.position)
            .SetInitRot(transform.rotation)
            .SetParent(parent.transform)
            .SetMovingToFalse(false);
         
        Destroy(electricTeslaTrap.gameObject.GetComponent<InventoryItem>());
        Destroy(gameObject);
    }
}
