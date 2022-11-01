using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Melee : MonoBehaviour
{
    //No usamos observer para hacer daño.
    //private List<IHittableObserver> _myHittableObservers = new List<IHittableObserver>();
    public Animator anim;
    protected Player _player;
    protected bool IsAttacking = false;
    [SerializeField]
    public int damageAmount;
    [SerializeField]
    protected int hitsRemaining;
    protected virtual void OnContactEffect(Collider other)
    {

    }

    public Melee SetOwner(Player player)
    {
        _player = player;
        return this;
    }

    public virtual void MeleeAttack()
    {

    }
    protected virtual void OnTriggerEnter(Collider other)
    {
        OnContactEffect(other);
    }

    public virtual void OnHitEffect()
    {

    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    //No usamos observer para hacer daño.
    /* public void AddObserver(IHittableObserver obs)
    {
        _myHittableObservers.Add(obs);
    }

    public void RemoveObserver(IHittableObserver obs)
    {
        if (_myHittableObservers.Contains(obs)) _myHittableObservers.Remove(obs);
    }

    public void TriggerHit(string triggerMessage)
    {
        _myHittableObservers.ForEach(x => x.OnNotify(triggerMessage));
    } */
}
