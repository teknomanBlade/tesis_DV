using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TeslaCoilGeneratorConstructAnim : MonoBehaviour, ITrapBuildable
{
    public GameObject trapPrefab;
    public Animator myAnimator;
    public GameObject parent;
    // Start is called before the first frame update
    void Start()
    {
        myAnimator = GetComponent<Animator>();
        parent = transform.parent.gameObject;
    }

    // Update is called once per frame
    public void FinishAnim()
    {
        var teslaCoilGenerator = GameVars.Values.TeslaCoilGeneratorPool.GetObject()
            .SetInitPos(transform.position)
            .SetInitRot(transform.rotation)
            .SetParent(parent.transform)
            .SetOwner(GameVars.Values.Player)
            .SetMovingToFalse(false);

        Destroy(teslaCoilGenerator.gameObject.GetComponent<InventoryItem>());
        Destroy(gameObject);
    }
}
