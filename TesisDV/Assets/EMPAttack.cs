using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EMPAttack : MonoBehaviour
{
    private Gray _owner;
    private bool _isAttacking;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    public EMPAttack SetOwner(Gray owner)
    {
        _owner = owner;
        _owner.OnGrayAttackChange += GrayAttackChanged;
        return this;
    }

    private void GrayAttackChanged(bool attack)
    {
        _isAttacking = attack;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (_isAttacking && other.gameObject.GetComponent<Player>() != null)
        {
            Debug.Log("ENTRO EN TRIGGER DAMAGE PLAYER??");
            _owner.TriggerPlayerDamage("DamagePlayer");
        }
    }

}
