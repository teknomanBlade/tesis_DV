using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseballLauncherAnim : MonoBehaviour
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
        //GameObject aux = Instantiate(trapPrefab, transform.position, transform.rotation, parent.transform);
        var baseballTrap = GameVars.Values.BaseballLauncherPool.GetObject()
            .SetInitPos(transform.position)
            .SetInitRot(transform.rotation)
            .SetParent(parent.transform);
         /*if (GameVars.Values.currentShotsTrap1 > 0) 
         {
             aux.GetComponent<BaseballLauncher>().shotsLeft = GameVars.Values.currentShotsTrap1;
             aux.GetComponent<BaseballLauncher>().RemoveVisualTennisBallsByShotsLeft();
         }*/

        Destroy(baseballTrap.gameObject.GetComponent<InventoryItem>());
        Destroy(gameObject);
    }
}
