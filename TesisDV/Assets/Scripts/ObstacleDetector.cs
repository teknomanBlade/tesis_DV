using System.Runtime.Serialization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObstacleDetector : MonoBehaviour
{
    [SerializeField] private Enemy _myOwner;
    void Start()
    {
        //_myOwner = transform.transform.GetComponent<Gray>();
    }

    void OnTriggerEnter(Collider other)
    {
        var door = other.GetComponent<Door>();
        var forceField = other.GetComponent<ForceField>();
        //var bTrap = other.GetComponent<BaseballLauncher>(); //Después cambiar cuando haya un script Trap.
        //Se usa el OverlapSphere del Gray para detectar trampas. Esto se usa para las puertas.


        if (door && !other.GetComponent<Door>().GetDoorStatus())
        {
            //_myOwner.GetDoor(other.GetComponent<Door>());
            _myOwner.GetDoor(other.GetComponent<Door>());
        }

        else if (forceField && other.GetComponent<ForceField>() && !_myOwner.hasObjective)
        {
            _myOwner._fsm.ChangeState(EnemyStatesEnum.AttackTrapState);
        }
    }
}
