using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//CAMBIO PARA MVC
//No hacemos daño por observer, quito el IHittableObservable.
public abstract class Projectile : MonoBehaviour
{
    //private List<IHittableObserver> _myHittableObservers = new List<IHittableObserver>();
    protected bool effectUp = true;
    protected bool dieOnImpact = true;
    //[SerializeField] protected float lifeTime = 3f;
    [SerializeField] protected int _damageAmount;

    protected virtual void Start()
    {
        //lifeTime = GameVars.Values.projectileLifeTime;
        //Destroy(gameObject, lifeTime);
    }

    protected virtual void OnContactEffect(Collider other)
    {
        /*if (effectUp)
        {
            Debug.Log("Hit Projectile" + collision.transform.name);
            if (collision.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer()))
            {
                
            }
            
            if (dieOnImpact) Destroy(gameObject);
            effectUp = false;
        }*/
    }

    /* protected void OnTriggerEnter(Collider other)
    {
        OnContactEffect(other);
    } */

   /*  public void AddObserver(IHittableObserver obs)
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
    } */
}
