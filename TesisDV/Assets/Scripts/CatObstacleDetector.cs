using System.Runtime.Serialization;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CatObstacleDetector : MonoBehaviour
{
    [SerializeField] private Cat _myOwner;

    void OnTriggerEnter(Collider other)
    {
        var door = other.GetComponent<Door>();

        if (door && !other.GetComponent<Door>().GetDoorStatus())
        {
            _myOwner.GetDoor(other.GetComponent<Door>());
        }
    }
}
