using System.Runtime.Serialization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObstacleDetector : MonoBehaviour
{
    [SerializeField]
    private Gray _myOwner;
    void Start()
    {
        //_myOwner = transform.transform.GetComponent<Gray>();
    }

    void OnTriggerEnter(Collider other)
    {
        var door = other.GetComponent<Door>();
        var bTrap = other.GetComponent<BaseballLauncher>(); //Después cambiar cuando haya un script Trap.


        if (door && !other.GetComponent<Door>().GetDoorStatus())
        {
            //_myOwner.GetDoor(other.GetComponent<Door>());
            _myOwner.FoundDoorInPath(other.GetComponent<Door>());
        }
        else if (bTrap && other.GetComponent<BaseballLauncher>())
        {
            _myOwner.FoundTrapInPath(other.GetComponent<BaseballLauncher>().gameObject);
        }
    }
}
