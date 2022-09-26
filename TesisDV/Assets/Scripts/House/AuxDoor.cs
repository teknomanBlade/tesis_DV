using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AuxDoor : MonoBehaviour
{
    public Door myDoor;

    public void Interact()
    {
        myDoor.Interact();
    }
}
