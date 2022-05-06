using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorTrigger : MonoBehaviour
{
    public EnumDoor enumDoor;
    
    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player")) { 
            this.gameObject.GetComponentInParent<Door>().IsFront = (enumDoor == EnumDoor.IsPlayerFront ? true : false);
            Debug.Log("Player is inside" + this.gameObject.name);
        }
    }

    
}
