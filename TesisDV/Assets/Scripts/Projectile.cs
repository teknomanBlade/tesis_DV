using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Projectile : MonoBehaviour
{
    float lifeTime = 2f;

    protected virtual void Start()
    {
        Destroy(gameObject, lifeTime);
    }

    protected virtual void OnContactEffect(Collision collision)
    {
        Debug.Log("Hit " + collision.transform.name);
        if (collision.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer())) collision.gameObject.GetComponent<Gray>().Stun();
        Destroy(gameObject);
    }

    protected virtual void OnCollisionEnter(Collision collision)
    {
        OnContactEffect(collision);
    }
}
