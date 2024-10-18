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
        //var player = other.GetComponent<Player>();
        var trap = other.GetComponent<Trap>();

        /*if (player)
        {
            //_myOwner.GetDoor(other.GetComponent<Door>());
            other.GetComponent<Player>().Damage(_damageAmount);
            
        }
        else*/

        if (trap && other.GetComponent<FERNPaintballMinigun>())
        {
            trap.Inactive();
            //_myOwner.RevertSpecialAttackBool();
        }

        if (trap && other.GetComponent<ElectricTrap>())
        {
            trap.Inactive();
            //_myOwner.RevertSpecialAttackBool();
        }

        if (trap && other.GetComponent<BaseballLauncher>())
        {
            trap.Inactive();
           // _myOwner.RevertSpecialAttackBool();
        }

        if (trap && other.GetComponent<ForceField>())
        {
            if (other.GetComponent<ForceField>().IsDamageReturn)
            {
                _myOwner.TakeDamage(other.GetComponent<ForceField>().DamageReturnAmount);
            }
            other.GetComponent<ForceField>().TakeDamage(_damageAmount);
        }
    }
}
