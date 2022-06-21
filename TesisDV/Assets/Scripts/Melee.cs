using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Melee : MonoBehaviour
{
    private List<IHittableObserver> _myHittableObservers = new List<IHittableObserver>();
    public Animator anim;
    protected bool IsAttacking = false;
    protected Player _owner;
    protected virtual void OnContactEffect(Collider other)
    {

    }

    public Melee SetOwner(Player player)
    {
        _owner = player;
        return this;
    }

    public virtual void MeleeAttack()
    {

    }
    protected virtual void OnTriggerEnter(Collider other)
    {
        OnContactEffect(other);
    }


    // Start is called before the first frame update
    void Start()
    {
        
    }

    public void AddObserver(IHittableObserver obs)
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
    }
}
