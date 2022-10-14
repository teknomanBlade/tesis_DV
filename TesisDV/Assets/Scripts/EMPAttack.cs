using System.Runtime.Serialization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EMPAttack : MonoBehaviour
{
    [SerializeField]
    private GrayModel _myOwner;
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
        if (trap && other.GetComponent<ElectricTrap>())
        {
            other.GetComponent<Trap>().Inactive();
        }

        if (trap && other.GetComponent<BaseballLauncher>())
        {
            other.GetComponent<Trap>().Inactive();
        }
    }
}
