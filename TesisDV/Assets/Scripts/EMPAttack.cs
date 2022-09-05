using System.Runtime.Serialization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EMPAttack : MonoBehaviour
{
    [SerializeField]
    private GrayModel _myOwner;
    [SerializeField] private int _damageAmount;

    void OnTriggerEnter(Collider other)
    {
        var player = other.GetComponent<Player>();
        var bTrap = other.GetComponent<BaseballLauncher>(); //Después cambiar cuando haya un script Trap.

        if (player)
        {
            //_myOwner.GetDoor(other.GetComponent<Door>());
            other.GetComponent<Player>().Damage(_damageAmount);
            
        }
        else if (bTrap && other.GetComponent<BaseballLauncher>())
        {
            other.GetComponent<BaseballLauncher>().Inactive();
        }
    }
}
