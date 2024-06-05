using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaintballPellet : Projectile
{
    private Rigidbody _rb;
    [SerializeField] private float _forceAmount; //Estamos en 35f.
    private bool _isPepperPelletActive;
    private bool _isDoubleDamageActive;
    private Vector3 shootDirection;
    private FERNPaintballMinigun _fpm;
    // Start is called before the first frame update
    protected override void Start()
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

    public PaintballPellet SetPepperPelletActive(bool pepperPelletActive)
    {
        _isPepperPelletActive = pepperPelletActive;
        if (_isPepperPelletActive) 
        {
            GetComponent<MeshRenderer>().material.SetFloat("_TransitionTextureVal", 1f);
        }
        return this;
    }

    public PaintballPellet SetAdditionalDamage(bool doubleDamageActive, int addDamage)
    {
        _isDoubleDamageActive = doubleDamageActive;
        if (_isDoubleDamageActive) 
        {
            _damageAmount += addDamage;
        }
        return this;
    }
    
}
