using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class InteractableObject : Object
{
    public override void Interaction()
    {
        Debug.Log("I'm a block");
    }
}
