using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaintballPellet : Projectile
{
    private Rigidbody _rb;
    [SerializeField] private float _forceAmount; //Estamos en 35f.
    private Vector3 shootDirection;
    private FERNPaintballMinigun _fpm;
    // Start is called before the first frame update
    void Start()
    {
        base.Start();
        Invoke("ReturnToPool", 5f);
        _rb = GetComponent<Rigidbody>();
        _rb.AddForce(_forceAmount * shootDirection, ForceMode.Impulse);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void ReturnToPool()
    {
        _fpm.PaintballPelletsPool.ReturnObject(this);
    }

    public PaintballPellet SetOwner(FERNPaintballMinigun fpm)
    {
        _fpm = fpm;
        return this;
    }
    public PaintballPellet SetOwnerForward(Vector3 forward)
    {
        shootDirection = forward;
        return this;
    }
    public PaintballPellet SetInitialPos(Vector3 pos)
    {
        transform.position = pos;
        return this;
    }

    public PaintballPellet SetAdditionalDamage(int addDamage)
    {
        _damageAmount += addDamage;
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
}
