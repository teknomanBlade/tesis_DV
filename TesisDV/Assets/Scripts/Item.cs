using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Item : MonoBehaviour
{
    string itemName { get { return itemName; } }
    Sprite itemImage { get { return itemImage; } }

    public void Interact()
    {
        
    }

    public void SetPos(Vector3 pos)
    {
        transform.position = pos;
    }

    public virtual void OnPickup()
    {

    }
}
