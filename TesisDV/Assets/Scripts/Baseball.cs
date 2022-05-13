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

    protected override void OnContactEffect(Collision collision)
    {
        if (effectUp)
        {
            Debug.Log("Hit " + collision.transform.name);
            if (collision.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer()))
            {
                effectUp = false;
                AddObserver(collision.gameObject.GetComponent<Gray>());
                TriggerHit("TennisBallHit");
            }
            if (dieOnImpact) Destroy(gameObject);
        }
    }
}
