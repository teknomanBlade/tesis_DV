using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Baseball : Projectile
{
    private Rigidbody _rb;
    [SerializeField] private float _forceAmount; //Estamos en 35f.
    private Vector3 shootDirection;
    private BaseballLauncher _bl;

    protected override void Start()
    {
        base.Start();
        _damageAmount = 1;
        Invoke("ReturnToPool",5f);
        _rb = GetComponent<Rigidbody>();
        _rb.AddForce(_forceAmount * shootDirection, ForceMode.Impulse);
    }

    public void ReturnToPool() 
    {
        _bl.BaseballPool.ReturnObject(this);
    }

    public Baseball SetOwner(BaseballLauncher bl)
    {
        _bl = bl;
        return this;
    }
    public Baseball SetOwnerForward(Vector3 forward)
    {
        shootDirection = forward;
        return this;
    }
    public Baseball SetInitialPos(Vector3 pos)
    {
        transform.position = pos;
        return this;
    }

    private void OnTriggerEnter(Collider other) 
    {
        var gray = other.GetComponent<Enemy>(); //Cambiar a la clase padre de Gray cuando lo armemos.

        if (gray)
        {
            //_myOwner.GetDoor(other.GetComponent<Door>());
            ReturnToPool();
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
