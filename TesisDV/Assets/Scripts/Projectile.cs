using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Projectile : MonoBehaviour, IHittableObservable
{
    private List<IHittableObserver> _myHittableObservers = new List<IHittableObserver>();
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
            if (collision.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer()))
            {
                AddObserver(collision.gameObject.GetComponent<Gray>());
                TriggerHit("TennisBallHit");
            }
            
            if (dieOnImpact) Destroy(gameObject);
            effectUp = false;
        }
    }

    protected virtual void OnCollisionEnter(Collision collision)
    {
        OnContactEffect(collision);
    }

    public void AddObserver(IHittableObserver obs)
    {
        _myHittableObservers.Add(obs);
    }

    public void RemoveObserver(IHittableObserver obs)
    {
        if(_myHittableObservers.Contains(obs)) _myHittableObservers.Remove(obs);
    }

    public void TriggerHit(string triggerMessage)
    {
        _myHittableObservers.ForEach(x => x.OnNotify(triggerMessage));
    }
}
