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
    public float currentTimeAnimUI;
    public float currentTimeAnimUISecond;
    [SerializeField] private MicrowaveForceFieldGenerator _myOwner;
    public delegate void OnForceFieldDownDelegate();
    public event OnForceFieldDownDelegate OnForceFieldDown;
    public delegate void OnForceFieldSecondaryDownDelegate();
    public event OnForceFieldSecondaryDownDelegate OnForceFieldSecondaryDown;
    void Awake()
    {
        _health = _initHealth = 20f;
        _myOwner = transform.parent.GetComponent<MicrowaveForceFieldGenerator>();
        OnForceFieldDown += _myOwner.OnForceFieldDown;
        if (_myOwner.SecondaryShieldActive)
        {
            currentTimeAnimUISecond = _health / _initHealth;
            _myOwner.UIAnimSecondShield.SetBool("IsSecondaryShield", _myOwner.SecondaryShieldActive);
            _myOwner.UIAnimSecondShield.SetFloat("ShieldHP_Secondary", currentTimeAnimUISecond);
            
        }
        
        active = true;
    }
    public void TakeDamage(float damageAmount)
    {
        Health -= damageAmount;
        if (_myOwner.SecondaryShieldActive)
        {
            currentTimeAnimUISecond = _health / _initHealth;
            _myOwner.UIAnimSecondShield.SetBool("IsSecondaryShield", _myOwner.SecondaryShieldActive);
            _myOwner.UIAnimSecondShield.SetFloat("ShieldHP_Secondary", currentTimeAnimUISecond);
            if (gameObject.name.Contains("Secondary") && Health <= 0)
            {
                currentTimeAnimUI = _health / _initHealth;
                _myOwner.UIAnimFirstShield.SetFloat("ShieldHP", currentTimeAnimUI);
            }
        }
        else 
        {
            currentTimeAnimUI = _health / _initHealth;
            _myOwner.UIAnimFirstShield.SetFloat("ShieldHP", currentTimeAnimUI);
        }
        
        if (Health <= 0f)
        {
            active = false;
            OnForceFieldDown();
            gameObject.SetActive(false);
        }
    }
    public void SetShieldPoints(float shieldPoints) 
    {
        Health = _initHealth = shieldPoints;
        active = true;
    }
    public void DamageReturned() 
    {
        DamageReturnAmount = 1.5f;
        IsDamageReturn = true;
    }
}
