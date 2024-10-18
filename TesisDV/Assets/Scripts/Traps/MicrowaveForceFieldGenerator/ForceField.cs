using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForceField : Trap
{
    [SerializeField] private float _health;
    [SerializeField] private float _initHealth;
    public bool IsDamageReturn;
    private float _damageReturnAmount;
    public float DamageReturnAmount { get{ return _damageReturnAmount; } set { _damageReturnAmount = value; } }
    public float Health { get { return _health; } set { _health = value; } }
    [SerializeField] private MicrowaveForceFieldGenerator _myOwner;
    void Awake()
    {
        _initHealth = 20f;
        _myOwner = transform.parent.GetComponent<MicrowaveForceFieldGenerator>();
        active = true;
    }

    public void TakeDamage(float damageAmount)
    {
        Health -= damageAmount;
        if (Health <= 0f)
        {
            active = false;
            _myOwner.Inactive();
            gameObject.SetActive(false);
        }
    }
    public void SetShieldPoints(float shieldPoints) 
    {
        Health += shieldPoints;
    }
    public void DamageReturned() 
    {
        DamageReturnAmount = 1.5f;
        IsDamageReturn = true;
    }
}
