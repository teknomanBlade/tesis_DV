using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Baseball : Projectile
{
    protected override void Start()
    {
        base.Start();
        _damageAmount = 1;
    }

    private void OnTriggerEnter(Collider other) 
    {
        var gray = other.GetComponent<Enemy>(); //Cambiar a la clase padre de Gray cuando lo armemos.

        if (gray)
        {
            //_myOwner.GetDoor(other.GetComponent<Door>());
            other.GetComponent<Enemy>().TakeDamage(_damageAmount);
        }
        
    }

    /* protected override void OnContactEffect(Collider collider)
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
    } */
}
