using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Projectile : MonoBehaviour
{
    protected bool effectUp = true;
    protected bool dieOnImpact = true;
    protected float lifeTime = 3f;

    protected virtual void Start()
    {
        lifeTime = GameVars.Values.projectileLifeTime;
        Destroy(gameObject, lifeTime);
    }

    protected virtual void OnContactEffect(Collision collision)
    {
        if (effectUp)
        {
            Debug.Log("Hit " + collision.transform.name);
            if (collision.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer())) collision.gameObject.GetComponent<Gray>().Stun(5f);
            if (dieOnImpact) Destroy(gameObject);
            effectUp = false;
        }
    }

    protected virtual void OnCollisionEnter(Collision collision)
    {
        OnContactEffect(collision);
    }
}
