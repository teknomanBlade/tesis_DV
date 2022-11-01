using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Remote : MonoBehaviour
{
    public Animator anim;
    protected AudioSource _as;
    protected Player _player;
    protected TVTrap _TVTrap;
    protected bool IsAtRange = false;
    // Start is called before the first frame update
    void Start()
    {
        
    }
    public Remote SetOwner(Player player)
    {
        _player = player;
        return this;
    }
    // Update is called once per frame
    void Update()
    {
        
    }
    public virtual void ActivatableAction()
    {

    }
}
