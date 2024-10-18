using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseballLauncherAnim : MonoBehaviour
{
    public GameObject trapPrefab;
    Animator myAnimator;
    public GameObject parent; 
    void Start()
    {
        myAnimator = GetComponent<Animator>();
        //parent = GameObject.Find("MainGame");
        parent = transform.parent.gameObject;
    }

    public void FinishAnim()
    {
        var baseballTrap = GameVars.Values.BaseballLauncherPool.GetObject()
            .SetInitPos(transform.position)
            .SetInitRot(transform.rotation)
            .SetParent(parent.transform)
            .SetShotsRemainingZero();

        Destroy(baseballTrap.gameObject.GetComponent<InventoryItem>());
        Destroy(gameObject);
    }
}
