using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Nail : Projectile
{
    private Rigidbody _rb;
    [SerializeField] private float _forceAmount;
    private NailFiringMachine _nfm;
    // Start is called before the first frame update
    protected override void Start()
    {
        //base.Start();
        _damageAmount = 5;
        Invoke("ReturnToPool",5f);
        _rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        _rb.AddForce(_forceAmount * _nfm.spawnPoint.transform.forward, ForceMode.Force);
    }
    public Nail SetOwner(NailFiringMachine nfm)
    {
        _nfm = nfm;
        return this;
    }
    public Nail SetInitialPos(Vector3 pos)
    {
        transform.position = pos;
        return this;
    }
    public void ReturnToPool() 
    {
        _nfm.NailsPool.ReturnObject(this);
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
}
