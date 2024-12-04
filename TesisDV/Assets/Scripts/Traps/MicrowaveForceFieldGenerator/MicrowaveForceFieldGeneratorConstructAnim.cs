using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MicrowaveForceFieldGeneratorConstructAnim : MonoBehaviour, ITrapBuildable
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
        var microwaveForceFieldGenerator = GameVars.Values.MicrowaveForceFieldGeneratorPool.GetObject()
            .SetInitPos(transform.position)
            .SetInitRot(transform.rotation)
            .SetParent(parent.transform)
            .SetMovingToFalse(false);

        Destroy(microwaveForceFieldGenerator.gameObject.GetComponent<InventoryItem>());
        Destroy(gameObject);
    }

}
