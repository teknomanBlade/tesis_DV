using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Baseball : Projectile
{
    protected override void Start()
    {
        dieOnImpact = false;
        base.Start();
    }

    protected override void OnContactEffect(Collider collider)
    {
        if (effectUp)
        {
            if (collider.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer()))
            {
                effectUp = false;
                dieOnImpact = true;
                AddObserver(collider.gameObject.GetComponent<Gray>());
                TriggerHit("TennisBallHit");
            }
            if (dieOnImpact) Destroy(gameObject);
        }
    }
}
