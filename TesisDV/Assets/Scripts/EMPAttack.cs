using System.Runtime.Serialization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EMPAttack : MonoBehaviour
{
    [SerializeField] private Enemy _myOwner;
    [SerializeField] private float _damageAmount;
    //[SerializeField] private int _damageAmount;

    void OnTriggerEnter(Collider other)
    {
        var trap = other.GetComponent<Trap>();

        if (trap && other.GetComponent<FERNPaintballMinigun>())
        {
            trap.Inactive();
        }

        if (trap && other.GetComponent<ElectricTrap>())
        {
            trap.Inactive();
        }

        if (trap && other.GetComponent<BaseballLauncher>())
        {
            trap.Inactive();
        }
        var forceField = other.GetComponent<ForceField>();
        if (trap && forceField)
        {
            if (forceField.name.Contains("Secondary") && forceField.Health > 0)
            {
                ForceFieldTakeDamage(forceField);
            }
            else 
            {
                ForceFieldTakeDamage(forceField);
            }
        }
    }

    public void ForceFieldTakeDamage(ForceField forceField) 
    {
        if (forceField.IsDamageReturn)
        {
            _myOwner.TakeDamage(forceField.DamageReturnAmount);
        }
        forceField.TakeDamage(_damageAmount);
    }
}
